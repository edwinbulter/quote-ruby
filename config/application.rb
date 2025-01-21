require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module QuoteRuby
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # CORS Configuration
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins 'http://localhost:3000', 'http://localhost:3001', 'http://localhost:3002' # Allowed origins (adjust as needed)
        resource '*', # Apply this rule to all paths/endpoints
                 headers: :any, # Allow all headers (e.g., JSON, custom headers)
                 methods: [:get, :post, :put, :patch, :delete, :options, :head], # Allow specific request methods
                 credentials: true # Allow cookies/credentials to be sent (if API requires this)
      end
    end
  end
end
