require File.expand_path('../boot', __FILE__)

require "active_record/railtie"
require "action_controller/railtie"

Bundler.require(*Rails.groups)

module Headbang
  USER_AGENT = "headbang/1.0"
  LASTFM_KEY = "84324111ccccaa831f917ca14114bd6e"
  STOP_WORDS = %w(the vinyl cd cds cdm dvd lp ep 7inch web)

  class Application < Rails::Application
    config.after_initialize do
      LastFM::Base.headers "user-agent" => Headbang::USER_AGENT
      LastFM::Base.api_key = Headbang::LASTFM_KEY
    end

    config.secret_token = SecureRandom.hex(128)
    config.middleware.use Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :delete, :put, :options], max_age: 0
      end
    end
  end
end
