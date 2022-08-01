# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :validate_token

  TOKEN_EXPIRATION_DAYS = 7.days

  def sign_in
    email = sign_in_params[:email]
    password = sign_in_params[:password]

    user = User.find_by(email:)
    if user&.authenticated?(password)
      token = JwtService.encode(user)
      cookies.signed[:jwt] = { value: token, httponly: true, expires: TOKEN_EXPIRATION_DAYS }
      render status: :ok
    else
      render json: { message: 'Invalid credentials' }, status: 401
    end
  end

  def sign_out
    cookies.delete(:jwt)
  end

  private

  def sign_in_params
    params.permit(:email, :password)
  end
end
