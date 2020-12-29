# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  confirmation_token :string(128)
#  email              :string           not null
#  encrypted_password :string(128)      not null
#  remember_token     :string(128)      not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_users_on_email           (email)
#  index_users_on_remember_token  (remember_token)
#
class User < ApplicationRecord
  include Clearance::User

  has_many :items, dependent: :destroy
  has_many :lists, dependent: :destroy
  has_many :tags, dependent: :destroy

  validates :email, :encrypted_password, presence: true
  validates :email, uniqueness: true

  after_create :create_default_lists, unless: -> { Rails.env.test? }

  private

  def create_default_lists
    List.create_defaults(self)
  end
end
