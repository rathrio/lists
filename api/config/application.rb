require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Load dotenv only in development or test environment
if ["development", "test"].include? ENV["RAILS_ENV"]
  Dotenv::Railtie.load
end

module Lists
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.api_only = true
    config.middleware.use ActionDispatch::Cookies

    # https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#autoloaded-paths-are-no-longer-in-$load-path
    config.add_autoload_paths_to_load_path = true

    # DEPRECATION WARNING: `to_time` will always preserve the receiver timezone
    # rather than system local time in Rails 8.1. To opt in to the new behavior,
    # set `config.active_support.to_time_preserves_timezone = :zone`.
    config.active_support.to_time_preserves_timezone = :zone

    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: "smtp.gmail.com",
      port: 587,
      domain: "lists.io",
      user_name: ENV["SMTP_USERNAME"],
      password: ENV["SMTP_PASSWORD"],
      authentication: "plain",
      enable_starttls: true,
      open_timeout: 5,
      read_timeout: 5,
    }

    config.mission_control.jobs.base_controller_class = "AdminController"
    config.mission_control.jobs.http_basic_auth_enabled = false

    config.solid_queue.silence_polling = true
  end

  def self.version
    @version ||= `git rev-parse --short HEAD`.chomp
  end

  def self.last_release
    `git log -1 --format=%cr HEAD`.chomp
  end
end
