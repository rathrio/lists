class ApplicationController < ActionController::API
  include ::ActionController::Cookies
  include SessionHelper

  before_action :validate_token

  private

  def validate_token
    token = cookies.signed[:jwt]
    data = JwtService.decode(token)
    data.first['user_id'].present?
  rescue JWT::DecodeError
    render json: { message: 'Invalid or missing token' }, status: 401
  end
end
