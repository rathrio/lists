# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :user

  validates :subject, presence: true
  validates :key, presence: true, uniqueness: true

  enum :email_status, unsent: 0, success: 1, error: 2, default: :unsent
end
