require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)
require "console1984"

module Dummy
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.console1984.protected_environments.push(* %i[ test development ])
    config.console1984.protected_urls = [ "localhost:#{6379}", "http://elastic:changeme@localhost:39201" ]

    config.active_record.encryption.encrypt_fixtures = true
  end
end
