class User < ApplicationRecord
  include Clearance::User

  has_many :items, dependent: :destroy
  has_many :labels, dependent: :destroy
  has_many :tags, dependent: :destroy

  validates :email, :encrypted_password, presence: true
  validates :email, uniqueness: true

  after_create :create_default_labels

  private

  def create_default_labels
    Label.create_defaults(self)
  end
end
