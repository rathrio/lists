source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6'
# Use postgres as the database for Active Record
gem 'pg'
# Use Puma as the app server
gem 'puma'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'hiredis'
gem 'redis', require: ["redis", "redis/connection/hiredis"]
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# A fast JSON parser and Object marshaller.
gem 'oj'

# Authentication
gem 'clearance'

# For attachments
gem 'carrierwave'

# Imagemagick interface
gem 'mini_magick'

# HTTP client
gem 'httparty'

# Softdelete
gem 'paranoia'

# Background jobs
# gem 'sidekiq'

# For packing frontend libs
gem 'webpacker', '>= 5.1.1'
gem 'react_on_rails'
# # For server-side react component rendering with react_on_rails
# gem 'libv8'
# gem 'therubyracer', platforms: :ruby
# gem 'execjs'

# Frontend
gem 'font-awesome-rails'
gem 'bulma-rails', '~> 0.9.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5'
# Use Uglifier as compressor for JavaScript assets
# gem 'uglifier', '>= 1.3.0'
# Use Yui as compressor for JavaScript assets
gem 'yui-compressor', '~> 0.12.0'

group :development, :test do
  gem 'dotenv-rails'
  gem 'pry-rails'
  gem 'pry-doc'
  gem 'pry-byebug'

  gem 'factory_bot_rails'
  gem 'ffaker'
end

group :development do
  gem 'rubocop'
  gem 'solargraph'
  gem 'foreman'
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'

  # A documentation generation tool
  gem 'yard'

  # Generate Entity-Relationship Diagrams
  gem "rails-erd"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
