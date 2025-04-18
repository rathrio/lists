# frozen_string_literal: true

class AdminController < ActionController::Base
  http_basic_authenticate_with name: ENV["ADMIN_USERNAME"], password: ENV["ADMIN_PASSWORD"]
end
