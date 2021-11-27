# frozen_string_literal: true

class ProfilesController < ApplicationController
  def update
    @profile = ProfileForm.new(profile_params.merge(user: current_user))

    if @profile.update
      render status: :ok
    else
      render status: 400
    end
  end

  private

  def profile_params
    params.permit(:current_password, :new_password, :new_password_confirmation)
  end
end
