# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :validate_token

  def sign_in
    email = sign_in_params[:email]
    password = sign_in_params[:password]

    user = User.find_by(email: email)
    if user&.authenticated?(password)
      secret = Rails.application.secrets.secret_key_base
      token = JWT.encode({ user_id: user.id }, secret, "HS256")
      cookies.signed[:jwt] = { value: token, httponly: true, expires: 1.day }
      render json: { email: user.email }
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
