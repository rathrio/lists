class ProfilesController < ApplicationController
  def show
    @profile = ProfileForm.new(user: current_user)
  end

  def update
    @profile = ProfileForm.new(profile_params.merge(user: current_user))

    if @profile.update
      flash[:notice] = 'Profile successfully updated'
    else
      flash[:alert] = 'Could not update profile'
    end

    redirect_to profile_path
  end

  private

  def profile_params
    params.require(:profile_form).
      permit(:current_password, :new_password, :new_password_confirmation)
  end
end
