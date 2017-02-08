class MoviedbClient
  include HTTParty
  base_uri 'https://api.themoviedb.org/3'
  default_params api_key: ENV['MOVIEDB_API_KEY']

  IMAGE_BASE_URI = 'https://image.tmdb.org/t/p/w500'

  def initialize(query: '')
    @query = query
  end

  def search(type: 'movie')
    self.class.get("/search/#{type}", query: { 'query' => @query })
  end
end
