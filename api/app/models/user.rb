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

  # @param token [String] plaintext API token, e.g. from a Bearer header
  # @return [User, nil]
  def self.find_by_api_token(token)
    return nil if token.blank?

    find_by(api_token: digest_api_token(token))
  end

  def self.digest_api_token(token)
    Digest::SHA256.hexdigest(token)
  end

  # Only the digest is stored, so the plaintext token is returned exactly
  # once. Replaces (and thereby revokes) any previous token.
  #
  # @return [String] plaintext API token
  def regenerate_api_token!
    token = "lists_#{SecureRandom.base58(40)}"
    update!(api_token: self.class.digest_api_token(token))
    token
  end

  def revoke_api_token!
    update!(api_token: nil)
  end

  private

  def create_default_lists
    List.create_defaults(self)
  end
end
