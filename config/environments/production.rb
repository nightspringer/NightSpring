# config/environments/production.rb
# frozen_string_literal: true

Rails.application.configure do
  config.asset_source = :sprockets

  config.cache_classes = true
  config.eager_load = true

  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Serve static files (for images like your logo)
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Precompiled assets only
  config.assets.compile = false

  config.log_level = ENV.fetch("LOG_LEVEL") { "info" }.to_sym
  config.log_tags = [ :request_id ]

  config.lograge.enabled = true

  cache_redis_url = ENV.fetch("CACHE_REDIS_URL") { nil }
  if cache_redis_url.present?
    config.cache_store = :redis_cache_store, {
      url: cache_redis_url,
      pool_size: ENV.fetch("RAILS_MAX_THREADS") { 5 }.to_i,
      pool_timeout: ENV.fetch("CACHE_REDIS_TIMEOUT") { 5 },
      error_handler: -> (method:, returning:, exception:) {
        Sentry.capture_exception exception, level: 'warning',
                                 tags: { method: method, returning: returning }
      },
    }
  end

  # Optional rebrand: set queue prefix to "nightspring"
  config.active_job.queue_name_prefix = "nightspring_#{Rails.env}"

  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true

  # Email defaults
  config.action_mailer.default_options[:reply_to] = ENV['SMTP_REPLY_TO'] if ENV['SMTP_REPLY_TO'].present?
  config.action_mailer.default_options[:return_path] = ENV['SMTP_RETURN_PATH'] if ENV['SMTP_RETURN_PATH'].present?

  enable_starttls = true
  enable_starttls_auto = true

  case ENV['SMTP_ENABLE_STARTTLS']
  when 'always'
    enable_starttls = true
  when 'never'
    enable_starttls = false
  when 'auto'
    enable_starttls_auto = true
  else
    enable_starttls_auto = ENV['SMTP_ENABLE_STARTTLS_AUTO'] != 'false'
  end

  config.action_mailer.smtp_settings = {
    port: '587',
    address: 'in-v3.mailjet.com',
    user_name: '4f7e235598456bf14b0940bfe09a8b8a',
    password:  '813526797bdb9c6e4e401034f76c0789',
    domain:    'nightspring.net',
    authentication: :login,
    openssl_verify_mode: 'none',
    enable_starttls: true,
    enable_starttls_auto: enable_starttls_auto,
    tls: ENV['SMTP_TLS'] == 'true',
    ssl: ENV['SMTP_SSL'] == 'true',
    read_timeout: 20,
  }

  config.i18n.fallbacks = [I18n.default_locale]
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  config.active_record.dump_schema_after_migration = false
end
