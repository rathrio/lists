class MovieScraper
  def initialize(query:)
    @query = query
  end

  def scrape
    movies = MoviedbClient.new(query: @query).search(type: :movie)['results'].to_a

    movies.map do |movie|
      url = if movie['poster_path']
              MoviedbClient::IMAGE_BASE_URI + movie['poster_path']
            else
              ''
            end

      release_date = if movie['release_date'].present?
                       Date.parse(movie['release_date'])
                     else
                       nil
                     end

      {
        name: movie['title'],
        description: movie['overview'],
        remote_image_url: url,
        release_date: release_date
      }
    end
  end
end
