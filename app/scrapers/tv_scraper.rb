class TvScraper
  include Scraper

  def search_results
    moviedb_client.search(query, type: :tv)['results'].to_a
  end

  def scrape_name(result)
    result['name']
  end

  def scrape_description(result)
    result['overview']
  end

  def scrape_image(result)
    MoviedbClient::IMAGE_BASE_URI + result['poster_path'] if result['poster_path']
  end

  def scrape_date(result)
    Date.parse(result['first_air_date']) if result['first_air_date'].present?
  end

  def scrape_tags(result)
    result['genre_ids'].map { |id| MoviedbClient::GENRES[id] }.compact
  end

  private

  def moviedb_client
    @moviedb_client ||= MoviedbClient.new
  end
end
