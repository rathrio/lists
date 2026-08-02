# frozen_string_literal: true

class JellyseerrClient
  include HTTParty
  base_uri ENV.fetch("JELLYSEERR_HOST")
  default_timeout 3

  class Error < StandardError; end

  def initialize
    @api_key = ENV.fetch("JELLYSEERR_API_KEY")
  end

  # @param tmdb_id [Integer, String]
  # @param type [Symbol] :movie or :tv
  # @return [Hash, nil] the title's "mediaInfo", or nil when Jellyseerr
  #   doesn't know it yet — the "never requested" case.
  def media_info(tmdb_id, type:)
    response = self.class.get("/api/v1/#{media_type(type)}/#{tmdb_id}", headers: headers)
    raise Error, "Jellyseerr media lookup failed (#{response.code})" unless response.success?

    response.parsed_response["mediaInfo"]
  end

  # @param tmdb_id [Integer, String]
  # @param type [Symbol] :movie or :tv
  # @return [Hash] the created request's "media"
  def request_media(tmdb_id, type:)
    body = { mediaType: media_type(type), mediaId: tmdb_id.to_i }
    body[:seasons] = "all" if type == :tv

    response = self.class.post(
      "/api/v1/request",
      body: body.to_json,
      headers: headers.merge("Content-Type" => "application/json")
    )
    unless response.success?
      raise Error, "Jellyseerr request failed (#{response.code}): #{response.body}"
    end

    response.parsed_response["media"]
  end

  private

  def media_type(type)
    type == :tv ? "tv" : "movie"
  end

  def headers
    { "X-Api-Key" => @api_key }
  end
end
