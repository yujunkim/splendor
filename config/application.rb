require File.expand_path('../boot', __FILE__)

#require 'rails/all'
#
require "action_controller/railtie"
require "action_mailer/railtie"
#require "active_resource/railtie"
require "rails/test_unit/railtie"
require "sprockets/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Splendor
  class Application < Rails::Application
    Record = {
      game: {},
      user: {}
    }
    Messages = []
    config.autoload_paths << Rails.root.join('lib')
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Seoul'
    # config.active_record.default_timezone = :local

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
  end
end
