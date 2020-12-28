# frozen_string_literal: true

# Used for acquiring an access token for the client credentials flow of the IGDB api.
class TwitchAuthClient
  include HTTParty

  CACHE_KEY = 'twitch-access-token'

  class Token
    # @param access_token [String]
    # @param expiration_time [Time]
    def initialize(access_token:, expiration_time:)
      @access_token = access_token
      @expiration_time = expiration_time
    end

    def expired?
      Time.now >= @expiration_time
    end

    # @return [String]
    def to_header
      "Bearer #{@access_token}"
    end
  end

  base_uri 'https://id.twitch.tv'
  default_params(
    client_id: ENV['TWITCH_CLIENT_ID'],
    client_secret: ENV['TWITCH_CLIENT_SECRET'],
    grant_type: 'client_credentials'
  )

  def self.auth_header
    new.token.to_header
  end

  # @return [Token]
  attr_reader :token

  def initialize
    @token = Rails.cache.fetch(CACHE_KEY, expires_in: 1.week) do
      response = self.class.post('/oauth2/token')
      raise response.message unless response.success?

      attributes = response.parsed_response

      Token.new(
        access_token: attributes.fetch('access_token'),
        expiration_time: Time.now + attributes.fetch('expires_in').to_i.seconds
      )
    end
  end
end
