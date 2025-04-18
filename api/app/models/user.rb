# frozen_string_literal: true

class User < ApplicationRecord
  include Clearance::User

  has_many :items, dependent: :destroy
  has_many :lists, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :notifications, dependent: :destroy

  validates :email, :encrypted_password, presence: true
  validates :email, uniqueness: true

  after_create :create_default_lists, unless: -> { Rails.env.test? }

  private

  def create_default_lists
    List.create_defaults(self)
  end
end
