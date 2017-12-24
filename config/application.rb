require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Lists
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.active_job.queue_adapter = :sidekiq
  end

  def self.version
    @version ||= `git rev-parse --short HEAD`.chomp
  end

  def self.last_release
    `git log -1 --format=%cr HEAD`.chomp
  end
end
