# Load the Rails application.
require_relative 'application'

# Setup ActiveSupport compatibility.
Oj.optimize_rails

# Initialize the Rails application.
Rails.application.initialize!
