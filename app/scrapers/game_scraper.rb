class GameScraper
  include Scraper

  def search_results
    igdb_client.search(query)
  end

  def scrape_name(result)
    result['name']
  end

  def scrape_description(result)
    result['summary']
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

  def scrape_tags(result)
    genres = igdb_client.genre(result['genres'])

    # Sometimes the first time just fails for whatever reason. Retry one more
    # time.
    # if genres.empty?
    #   genres = igdb_client.genre(result['genres'])
    # end

    genres.map { |g| g['name'] }.uniq.compact
  end

  private

  def igdb_client
    @igdb_client ||= IgdbClient.new
  end
end
