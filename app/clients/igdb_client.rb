# frozen_string_literal: true

require 'net/https'

# https://api-docs.igdb.com/
class IgdbClient
  HOST = 'api-v3.igdb.com'
  HTTP = Net::HTTP.new(HOST, 80)

  FIELDS = %w[
    game.name
    game.summary
    game.genres.name
    game.cover.url
    game.first_release_date
  ].freeze

  def search(query)
    request = Net::HTTP::Get.new(URI("https://#{HOST}/search"), 'user-key' => ENV['IGDB_API_KEY'])

    apicalypse_query = +"fields #{FIELDS.join(',')};"
    apicalypse_query << %{search "#{query}";}
    apicalypse_query << 'where game != null;'
    request.body = apicalypse_query

    response_body = HTTP.request(request).body
    return [] if response_body.blank?

    Oj.load(response_body).map { |result| result['game'] }
  end
end
