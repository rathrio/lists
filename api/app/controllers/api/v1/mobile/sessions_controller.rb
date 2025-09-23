# frozen_string_literal: true

class Api::V1::Mobile::SessionsController < ApplicationController
  skip_before_action :validate_token, only: [:sign_in, :sign_out]

  def sign_in
    email = sign_in_params[:email]
    password = sign_in_params[:password]

    user = User.find_by(email:)
    if user&.authenticated?(password)
      token = JwtService.encode(user)
      render json: { token: token }, status: :ok
    else
      render json: { message: 'Invalid credentials' }, status: 401
    end
  end

  def sign_out
    render json: { message: 'Signed out successfully' }, status: :ok
  end

  private

  def sign_in_params
    params.permit(:email, :password)
  end
end