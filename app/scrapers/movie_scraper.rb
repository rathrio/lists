class MovieScraper
  include Scraper

  def self.human_status_names
    @human_status_names ||= {
      todo: 'To Watch',
      doing: 'Watching',
      done: 'Watched'
    }
  end

  def search_results
    moviedb_client.search(query, type: :movie, filter_values: filter_values)['results'].to_a
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

  private

  def moviedb_client
    @moviedb_client ||= MoviedbClient.new
  end
end
