# frozen_string_literal: true

require_relative "boot"

require "rails"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
require "active_job/railtie"
require "action_cable/engine"
require "sprockets/railtie"

start = Time.now
Bundler.require(*Rails.groups)
puts "processing time of bundler require: #{(Time.now - start).round(3).to_s.ljust(5, '0')}s".light_green

module Retrospring
  class Application < Rails::Application
    config.load_defaults 7.0

    config.autoload_once_paths << config.root.join("lib")
    config.eager_load_paths << config.root.join("lib")
    config.add_autoload_paths_to_load_path = false

    config.active_job.queue_adapter = :sidekiq

    config.i18n.default_locale = "en"
    config.i18n.fallbacks = [I18n.default_locale]
    config.i18n.enforce_available_locales = false

    config.action_dispatch.rescue_responses["Pundit::NotAuthorizedError"] = :forbidden
  end
end
