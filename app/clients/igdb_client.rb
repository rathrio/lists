# frozen_string_literal: true

# https://api-docs.igdb.com/
class IgdbClient
  include HTTParty
  base_uri 'https://api-v3.igdb.com'
  headers 'user-key' => ENV['IGDB_API_KEY']

  FIELDS = %w[
    game.name
    game.summary
    game.genres.name
    game.cover.url
    game.first_release_date
  ].freeze

  def search(query)
    apicalypse_query = +"fields #{FIELDS.join(',')};"
    apicalypse_query << %{search "#{query}";}
    apicalypse_query << 'where game != null;'
    response = self.class.get('/search', body: apicalypse_query)
    return [] if response.nil? || response.empty?

    response.map { |hash| hash['game'] }.select { |hash| hash.is_a? Hash }
  end
end
