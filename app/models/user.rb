class User < ApplicationRecord
  include Clearance::User

  validates :email, :encrypted_password, presence: true
end
