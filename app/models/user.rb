# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  email              :string           not null
#  encrypted_password :string(128)      not null
#  confirmation_token :string(128)
#  remember_token     :string(128)      not null
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
