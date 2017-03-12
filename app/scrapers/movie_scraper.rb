class MovieScraper
  include Scraper

  def search_results
    title = query.gsub(/\((\d{2,4})\)/, '').strip
    moviedb_client.search(title, type: :movie, year: $1)['results'].to_a
  end

  def scrape_name(result)
    result['title']
  end

  def scrape_description(result)
    result['overview']
  end

  def scrape_image(result)
    MoviedbClient::IMAGE_BASE_URI + result['poster_path'] if result['poster_path']
  end

  def scrape_date(result)
    Date.parse(result['release_date']) if result['release_date'].present?
  end

  def scrape_tags(result)
    result['genre_ids'].map { |id| MoviedbClient::GENRES[id] }.uniq.compact
  end

  def reliable?(result)
    result['popularity'] > 4
  end

  private

  def moviedb_client
    @moviedb_client ||= MoviedbClient.new
  end
end
