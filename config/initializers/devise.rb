Devise.setup do |config|
  config.secret_key = ENV['SECRET_KEY_BASE'] || 'mTJZ5tQkAX5yNyrwcQ3xhR4dOKhh8IFNfIbiR8/3Kxc='

  config.mailer_sender = ENV.fetch('SMTP_FROM', 'NightSpring <noreply@nightspring.net>')
  config.mailer = 'Retromail'

  require 'devise/orm/active_record'

  config.authentication_keys = [:login]
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.skip_session_storage = [:http_auth]

  config.stretches = Rails.env.test? ? 1 : 10
  config.reconfirmable = true
  config.confirmation_keys = [:screen_name]
  config.password_length = 8..128
  config.reset_password_keys = [:email]
  config.reset_password_within = 6.hours

  config.sign_out_via = :delete

  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other
end
