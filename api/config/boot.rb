ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

# https://github.com/Shopify/bootsnap?tab=readme-ov-file#usage
require 'bootsnap/setup'
