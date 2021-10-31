class ProfileForm
  include ActiveModel::Model

  attr_accessor :user, :email, :current_password, :new_password,
    :new_password_confirmation

  validates :current_password, :new_password, :new_password_confirmation,
    presence: true

  delegate :email, to: :user

  def update
    unless valid? && current_password_correct? && new_password_matches_confirmation?
      return false
    end

    user.update(password: new_password)
  end

  private

  def current_password_correct?
    User.authenticate(email, current_password) == user
  end

  def new_password_matches_confirmation?
    new_password == new_password_confirmation
  end
end
