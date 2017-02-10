class MovieScraper
  include Scraper

  def search_results
    MoviedbClient.new(query: query).search(type: :movie)['results'].to_a
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
end
