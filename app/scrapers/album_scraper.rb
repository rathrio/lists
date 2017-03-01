class AlbumScraper
  include Scraper

  rely_on :discogs_client do |query|
    discogs_client.search(query, type: 'release')['results'].to_a
  end

  scrape_attribute :name do |result|
    result['title']
  end

  scrape_attribute :description do |result|
  end

  scrape_attribute :image do |result|
    result['thumb']
  end

  scrape_attribute :date do |result|
    Date.new(result['year'].to_i) if result['year'].present?
  end

  scrape_attribute :links do |result|
    [Link.new(url: result['resource_url'])]
  end

  scrape_attribute :tags do |result|
    result['style'].uniq.compact
  end

end
