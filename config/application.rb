require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"

Bundler.require(*Rails.groups)

module ApiTracker
  class Application < Rails::Application
    config.load_defaults 8.0
    config.api_only = true

    config.time_zone = "Europe/Moscow"
    config.active_record.default_timezone = :local

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins "*"
        resource "*", headers: :any, methods: %i[get post put patch delete options head]
      end
    end
  end
end
