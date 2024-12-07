# frozen_string_literal: true

class JwtService
  JWT_ALGORITHM = "HS256"

  def self.secret
    Rails.application.credentials.secret_key_base
  end

  # @param user [User]
  # @return [String] JWT
  def self.encode(user)
    JWT.encode({ user_id: user.id }, secret, JWT_ALGORITHM)
  end

  # @param token [String]
  # @return [Array]
  def self.decode(token)
    JWT.decode(token, secret, true, algorithm: JWT_ALGORITHM)
  end
end
