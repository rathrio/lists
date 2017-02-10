class GameScraper
  include Scraper

  def search_results
    IgdbClient.new(query: query).search
  end

  def scrape_name(result)
    result['name']
  end

  def scrape_description(result)
    result['description']
  end

  def scrape_image(result)
    url = result.dig('cover', 'url')

    if url.present?
      url = url.sub("//", "https://")
      url = url.sub("t_thumb", "t_cover_big")
    end
  end

  def scrape_date(result)
    release_date_unix = result['first_release_date'].to_s
    return nil unless release_date_unix.present?

    DateTime.strptime(release_date_unix,'%Q')
  end

  def scrape_links(result)
    [
      Link.new(url: result['url'])
    ]
  end
end
