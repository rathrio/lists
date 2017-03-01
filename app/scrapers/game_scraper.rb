class GameScraper
  include Scraper

  rely_on :igdb_client do |query|
    igdb_client.search(query)
  end

  scrape_attribute :name do |result|
    result['name']
  end

  scrape_attribute :description do |result|
    result['summary']
  end

  scrape_attribute :image do |result|
    url = result.dig('cover', 'url')

    if url.present?
      url = url.sub("//", "https://")
      url = url.sub("t_thumb", "t_cover_big")
    end
  end

  scrape_attribute :date do |result|
    release_date_unix = result['first_release_date'].to_s
    if release_date_unix.present?
      DateTime.strptime(release_date_unix,'%Q')
    else
      nil
    end
  end

  scrape_attribute :links do |result|
    [ Link.new(url: result['url']) ]
  end

  scrape_attribute :tags do |result|
    genres = igdb_client.genre(result['genres'])
    genres.map { |g| g['name'] }.uniq.compact
  end

end
