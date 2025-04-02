# config/environments/production.rb
# frozen_string_literal: true

Rails.application.configure do
  config.asset_source = :sprockets

  config.cache_classes = true
  config.eager_load = true

  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Serve static files
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Precompiled assets only
  config.assets.compile = false

  # Enforce HTTPS
  config.force_ssl = true

  # Allowed domains
  config.hosts << "nightspring.net"
  config.hosts << "nightspring.onrender.com"
  config.hosts += ENV.fetch("ALLOWED_HOSTS", "").split(",").map(&:strip)

  config.log_level = ENV.fetch("LOG_LEVEL", "info").to_sym
  config.log_tags = [:request_id]

  config.lograge.enabled = true

  # Redis cache store
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

  # Sidekiq / job queue prefix
  config.active_job.queue_name_prefix = "nightspring_#{Rails.env}"

  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true

  # Default mail headers
  config.action_mailer.default_options = {
    from: ENV['SMTP_FROM'] || 'NightSpring <noreply@nightspring.net>',
    reply_to: ENV['SMTP_REPLY_TO'] || 'contact@nightspring.net',
    return_path: ENV['SMTP_RETURN_PATH'] || 'contact@nightspring.net'
  }.compact

  # Links in email (e.g. confirmation, reset)
  config.action_mailer.default_url_options = {
    host: ENV.fetch("MAILER_HOST", "nightspring.net"),
    protocol: "https"
  }

  # STARTTLS behavior
  enable_starttls = true
  enable_starttls_auto = true
  case ENV['SMTP_ENABLE_STARTTLS']
  when 'always' then enable_starttls = true
  when 'never' then enable_starttls = false
  when 'auto' then enable_starttls_auto = true
  else
    enable_starttls_auto = ENV['SMTP_ENABLE_STARTTLS_AUTO'] != 'false'
  end

  # SMTP config (Mailjet or Private Email via ENV)
  config.action_mailer.smtp_settings = {
    address: 'mail.privateemail.com',
    port: 587,
    domain: 'nightspring.net',
    authentication: :login,
    user_name: ENV.fetch('SMTP_USERNAME'),
    password: ENV.fetch('SMTP_PASSWORD'),
    enable_starttls: enable_starttls,
    enable_starttls_auto: enable_starttls_auto,
    openssl_verify_mode: 'none',
    tls: ENV['SMTP_TLS'] == 'true',
    ssl: ENV['SMTP_SSL'] == 'true',
    read_timeout: 20
  }

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
