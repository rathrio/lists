class ApplicationController < ActionController::API
  include ::ActionController::Cookies
  include SessionHelper

  before_action :validate_token

  private

  def validate_token
    token = extract_token
    data = JwtService.decode(token)
    data.first["user_id"].present?
  rescue JWT::DecodeError
    render json: { message: "Invalid or missing token" }, status: 401
  end

  def extract_token
    # Try Bearer token first (mobile), then cookie (web)
    if request.headers['Authorization'].present?
      request.headers['Authorization'].split(' ').last
    else
      cookies.signed[:jwt]
    end
  end
end
