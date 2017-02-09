class TvScraper
  def initialize(query:)
    @query = query
  end

  def scrape
    shows = MoviedbClient.new(query: @query).search(type: :tv)['results'].to_a

    shows.map do |show|
      url = if show['poster_path']
              MoviedbClient::IMAGE_BASE_URI + show['poster_path']
            else
              ''
            end

      date = if show['first_air_date'].present?
               Date.parse(show['first_air_date'])
             else
               nil
             end

      {
        name: show['name'],
        description: show['overview'],
        remote_image_url: url,
        date: date
      }
    end
  end
  
end
