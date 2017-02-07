class GameScraper
  def initialize(query:)
    @query = query
  end

  def scrape
    games = IgdbClient.new(query: @query).search

    games.map do |game|
      url = game.dig('cover', 'url')
      url = url.sub("//", "https://") if url.present?

      links = [
        Link.new(url: game['url'])
      ]

      {
        name: game['name'],
        description: game['summary'],
        remote_image_url: url,
        links: links
      }
    end
  end
end
