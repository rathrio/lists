# frozen_string_literal: true

# https://api-docs.igdb.com/
class IgdbClient
  include HTTParty

  base_uri 'https://api.igdb.com/v4'
  headers 'Client-ID': ENV['TWITCH_CLIENT_ID'], 'Authorization': TwitchAuthClient.auth_header

  FIELDS = %w[
    game.name
    game.summary
    game.genres.name
    game.cover.url
    game.first_release_date
  ].freeze

  # @param search [String]
  # @param filter_values [Array<FilterValue>]
  def search(query, filter_values:)
    apicalypse_query = +"fields #{FIELDS.join(',')};"
    apicalypse_query << %{search "#{query}";}
    apicalypse_query << 'where game != null'

    filter_values.each do |filter_value|
      filter = filter_value['filter']
      value = filter_value['value']

      case filter
      when 'year'
        year = value.to_i
        start_time = Time.new(year).to_i
        end_time = Time.new(year, 12, 31).to_i

        apicalypse_query << "& game.first_release_date >= #{start_time} & game.first_release_date <= #{end_time}"
      end
    end

    apicalypse_query << ';'
    response = self.class.post('/search', body: apicalypse_query)
    return [] if response.nil? || response.empty?

    response.map { |hash| hash['game'] }.select { |hash| hash.is_a? Hash }
  end
end
