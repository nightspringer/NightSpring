# config/environments/production.rb
# frozen_string_literal: true

Rails.application.configure do
  config.asset_source = :sprockets

  config.cache_classes = true
  config.eager_load = true

  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.assets.compile = false
  config.force_ssl = true

  config.hosts << "nightspring.net"
  config.hosts << "nightspring.onrender.com"
  config.hosts += ENV.fetch("ALLOWED_HOSTS", "").split(",").map(&:strip)

  config.log_level = ENV.fetch("LOG_LEVEL", "info").to_sym
  config.log_tags = [:request_id]
  config.lograge.enabled = true

  cache_redis_url = ENV.fetch("CACHE_REDIS_URL", nil)
  if cache_redis_url.present?
    config.cache_store = :redis_cache_store, {
      url: cache_redis_url,
      pool_size: ENV.fetch("RAILS_MAX_THREADS", 5).to_i,
      pool_timeout: ENV.fetch("CACHE_REDIS_TIMEOUT", 5),
      error_handler: ->(method:, returning:, exception:) {
        Sentry.capture_exception exception, level: 'warning',
                                 tags: { method: method, returning: returning }
      }
    }
  end

  config.active_job.queue_name_prefix = "nightspring_#{Rails.env}"

  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true

  config.action_mailer.default_options = {
    from: ENV['SMTP_FROM'] || 'NightSpring <noreply@nightspring.net>',
    reply_to: ENV['SMTP_REPLY_TO'] || 'contact@nightspring.net',
    return_path: ENV['SMTP_RETURN_PATH'] || 'contact@nightspring.net'
  }.compact

  config.action_mailer.default_url_options = {
    host: ENV.fetch("MAILER_HOST", "nightspring.net"),
    protocol: "https"
  }

  enable_starttls = true
  enable_starttls_auto = true

  case ENV['SMTP_ENABLE_STARTTLS']
  when 'always' then enable_starttls = true
  when 'never' then enable_starttls = false
  when 'auto' then enable_starttls_auto = true
  else
    enable_starttls_auto = ENV['SMTP_ENABLE_STARTTLS_AUTO'] != 'false'
  end

  # Avoid errors during asset precompile (no ENV in build context)
  if ENV['SMTP_USERNAME'].present? && ENV['SMTP_PASSWORD'].present?
    unless Rails.const_defined?(:Console) || Rails.env.test? || defined?(Rake)
      config.action_mailer.smtp_settings = {
        address: 'mail.privateemail.com',
        port: 587,
        domain: 'nightspring.net',
        authentication: :login,
        user_name: ENV['SMTP_USERNAME'],
        password: ENV['SMTP_PASSWORD'],
        enable_starttls: enable_starttls,
        enable_starttls_auto: enable_starttls_auto,
        openssl_verify_mode: 'none',
        tls: ENV['SMTP_TLS'] == 'true',
        ssl: ENV['SMTP_SSL'] == 'true',
        read_timeout: 20
      }
    end
  end

  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  config.active_record.dump_schema_after_migration = false
end
