class GameScraper
  def initialize(query:)
    @query = query
  end

  def scrape
    games = IgdbClient.new(query: @query).search

    games.map do |game|
      url = game.dig('cover', 'url')
      url = url.sub("//", "https://") if url.present?

      release_date_unix = game['first_release_date'].to_s[0..9]
      release_date  = if release_date_unix.present?
                        DateTime.strptime(release_date_unix,'%s')
                      else
                        nil
                      end

      links = [
        Link.new(url: game['url'])
      ]

      {
        name: game['name'],
        description: game['summary'],
        remote_image_url: url,
        release_date: release_date,
        links: links
      }
    end
  end
end
