# frozen_string_literal: true

source "https://rubygems.org"

# Core Framework
gem "rails", "~> 7.1"
gem "pg"
gem "puma"

# UI & Asset Pipeline
gem "sassc-rails"
gem "sprockets", "~> 4.2"
gem "sprockets-rails", require: "sprockets/railtie"
gem "cssbundling-rails", "~> 1.4"
gem "jsbundling-rails", "~> 1.3"

# Hotwire
gem "turbo-rails"

# Authentication
gem "bcrypt", "~> 3.1.20"
gem "devise", "~> 4.9"
gem "devise-async"

# Image & Uploads
gem "mini_magick"
gem "carrierwave", "~> 2.1"
gem "carrierwave_backgrounder", "~> 0.4.2"

# Form Helpers & Views
gem "bootstrap_form", "~> 5.0"
gem "view_component"
gem "haml", "~> 6.3"

# Background Jobs
gem "sidekiq", "< 7"
gem "sidekiq-scheduler"
gem "redis"
gem "connection_pool"

# Admin
gem "rails_admin"
gem "pghero"

# Authorization
gem "pundit", "~> 2.5"
gem "rolify", "~> 6.0"

# Push Notifications
gem "rpush"
gem "web-push"

# External Services
gem "httparty"
gem "fog-aws"
gem "fog-core"
gem "fog-local"

# Security & Anti-Spam
gem "sanitize"
gem "hcaptcha", git: "https://github.com/retrospring/hcaptcha", ref: "fix/flash-in-turbo-streams"
gem "fake_email_validator"
gem "tldv", "~> 0.1.0"

# Utility
gem "colorize"
gem "oj"
gem "rqrcode"
gem "jwt", "~> 2.10"
gem "rubyzip", "~> 2.4"

# Metrics & Monitoring
gem "sentry-rails"
gem "sentry-ruby"
gem "sentry-sidekiq"
gem "lograge"
gem "prometheus-client", "~> 4.2"

# Text Processing
gem "redcarpet"
gem "twitter-text"

# OTP
gem "active_model_otp"

# Custom
gem "questiongenerator", "~> 1.1"

# Mail fixes
gem "net-imap"
gem "net-pop"
gem "net-smtp"
gem "mail", "~> 2.7.1"
gem "openssl", "~> 3.3"

# Performance
gem "bootsnap", require: false

# Development
group :development do
  gem "binding_of_caller"
end

# Dev + Test
group :development, :test do
  gem "dotenv-rails", "~> 3.1"
  gem "better_errors"
  gem "bullet"
  gem "faker"
  gem "factory_bot_rails", require: false
  gem "database_cleaner"
  gem "rails-controller-testing"
  gem "rake"
  gem "rspec-rails", "~> 7.1"
  gem "rspec-mocks"
  gem "rspec-its", "~> 2.0"
  gem "rspec-sidekiq", "~> 5.1", require: false
  gem "rubocop", "~> 1.74"
  gem "rubocop-rails", "~> 2.30"
  gem "shoulda-matchers", "~> 6.4"
  gem "simplecov", require: false
  gem "simplecov-json", require: false
  gem "simplecov-cobertura", require: false
  gem "haml_lint", require: false
  gem "json-schema"
  gem "letter_opener"
end
