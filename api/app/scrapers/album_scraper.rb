class AlbumScraper
  include Scraper

  def search_results
    discogs_client.search(query, type: 'release')['results'].to_a
  end

  def scrape_name(result)
    result['title']
  end

  def scrape_description(result)
  end

  def scrape_image(result)
    result['thumb']
  end

  def scrape_date(result)
    Date.new(result['year'].to_i) if result['year'].present?
  end

  def scrape_links(result)
    [
      Link.new(url: result['resource_url'])
    ]
  end

  def scrape_tags(result)
    result['style'].uniq.compact
  end

  private

  def discogs_client
    @discogs_client ||= DiscogsClient.new
  end
end
