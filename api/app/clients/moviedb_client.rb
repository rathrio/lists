# frozen_string_literal: true

class MoviedbClient
  include HTTParty
  base_uri 'https://api.themoviedb.org/3'
  default_params api_key: ENV['MOVIEDB_API_KEY']

  POSTER_BASE_URI = 'https://image.tmdb.org/t/p/w500'
  BACKDROP_BASE_URI = 'https://image.tmdb.org/t/p/w1280'

  GENRES = {
    28 => 'Action & Adventure',
    12 => 'Action & Adventure',
    10_759 => 'Action & Adventure',
    16 => 'Animation',
    35 => 'Comedy',
    80 => 'Crime',
    99 => 'Documentary',
    18 => 'Drama',
    10_751 => 'Family',
    10_762 => 'Kids',
    36 => 'History',
    27 => 'Horror',
    10_402 => 'Music',
    9648 => 'Mystery',
    10_763 => 'News',
    10_764 => 'Reality',
    10_749 => 'Romance',
    14 => 'SciFi & Fantasy',
    878 => 'SciFi & Fantasy',
    10_765 => 'SciFi & Fantasy',
    10_766 => 'Soap',
    # 10767 => "Talk",
    53 => 'Thriller',
    10_770 => 'TV Movie',
    10_767 => 'War & Politics',
    10_752 => 'War',
    37 => 'Western'
  }.freeze

  def search(query, type: 'movie', filter_values:)
    params = { query: query }

    filter_values.each do |filter_value|
      filter = filter_value['filter']
      value = filter_value['value']

      case filter
      when 'year'
        year = value.to_i
        params.merge!(year: year, first_air_date_year: year)
      end
    end

    self.class.get("/search/#{type}", query: params)
  end
end
