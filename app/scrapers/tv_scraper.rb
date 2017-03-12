class TvScraper
  include Scraper

  def search_results
    title = query.gsub(/\((\d{2,4})\)/, '').strip
    moviedb_client.search(title, type: :tv, year: $1)['results'].to_a
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

  def reliable?(result)
    result['popularity'] > 1.5
  end

  private

  def moviedb_client
    @moviedb_client ||= MoviedbClient.new
  end
end
