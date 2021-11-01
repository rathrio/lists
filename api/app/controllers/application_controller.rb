class ApplicationController < ActionController::API
  include ::ActionController::Cookies
  include SessionHelper
  # include Clearance::Controller

  before_action :validate_token

  private

  def validate_token
    token = cookies.signed[:jwt]
    data = jwt_decode(token)
    data.first['user_id'].present?
  rescue JWT::DecodeError
    render json: { message: 'Invalid token' }, status: 401
  end
end
