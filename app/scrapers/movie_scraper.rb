class MovieScraper
  include Scraper

  rely_on :moviedb_client do |query|
    title = query.gsub(/\((\d{2,4})\)/, '').strip
    moviedb_client.search(title, type: :movie, year: $1)['results'].to_a
  end

  scrape_attribute :name do |result|
    result['title']
  end

  scrape_attribute :description do |result|
    result['overview']
  end

  scrape_attribute :image do |result|
    MoviedbClient::IMAGE_BASE_URI + result['poster_path'] if result['poster_path']
  end

  scrape_attribute :date do |result|
    Date.parse(result['release_date']) if result['release_date'].present?
  end

  scrape_attribute :tags do |result|
    result['genre_ids'].map { |id| MoviedbClient::GENRES[id] }.uniq.compact
  end

end
