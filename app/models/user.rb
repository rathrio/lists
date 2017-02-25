class User < ApplicationRecord
  include Clearance::User

  has_many :items, dependent: :destroy
  has_many :labels, dependent: :destroy
  has_many :tags, dependent: :destroy

  validates :email, :encrypted_password, presence: true
end
