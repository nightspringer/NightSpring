# frozen_string_literal: true

module NightSpring
  module Config
    module_function

    def config_hash
      {}.with_indifferent_access.tap do |hash|
        # Load local YAML config (justask.yml renamed for NightSpring)
        yml_path = Rails.root.join("config/justask.yml")
        hash.merge!(YAML.load_file(yml_path)) if File.exist?(yml_path)

        # Optional overrides from ENV
        env_config = {
          site_name: ENV["SITE_NAME"],
          hostname: ENV["HOSTNAME"],
          https: ENV["HTTPS"]&.downcase == "true"
        }.compact

        hash.merge!(env_config)

        # Update default mail host for Devise and others
        Rails.application.config.action_mailer.default_url_options = {
          host: hash["hostname"],
          protocol: hash["https"] ? "https" : "http"
        }
      end
    end

    def registrations_enabled? = feature_enabled?(:registration)
    def advanced_frontpage_enabled? = feature_enabled?(:advanced_frontpage)
    def readonly? = feature_enabled?(:readonly)

    def feature_enabled?(feature) = APP_CONFIG.dig(:features, feature, :enabled)
  end
end
