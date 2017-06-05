class ApplicationController < ActionController::Base
  include SessionHelper
  include Clearance::Controller
  before_action :require_login

  protect_from_forgery with: :exception
end
