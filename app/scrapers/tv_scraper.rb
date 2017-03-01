class TvScraper
  include Scraper

  rely_on :moviedb_client do |query|
    title = query.gsub(/\((\d{2,4})\)/, '').strip
    moviedb_client.search(title, type: :tv, year: $1)['results'].to_a
  end

  scrape_attribute :name do |result|
    result['name']
  end

  scrape_attribute :description do |result|
    result['overview']
  end

  scrape_attribute :image do |result|
    MoviedbClient::IMAGE_BASE_URI + result['poster_path'] if result['poster_path']
  end

  scrape_attribute :date do |result|
    Date.parse(result['first_air_date']) if result['first_air_date'].present?
  end

  scrape_attribute :tags do |result|
    result['genre_ids'].map { |id| MoviedbClient::GENRES[id] }.compact
  end

end
