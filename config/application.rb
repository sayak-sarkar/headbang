require File.expand_path('../boot', __FILE__)

require "active_record/railtie"
require "action_controller/railtie"

Bundler.require(*Rails.groups)

module Headbang
  USER_AGENT = "headbang/1.0"
  STOP_WORDS = %w(the vinyl cd cds cdm dvd lp ep 7inch web)

  class Application < Rails::Application
  end
end
