class Scraper

  def self.all
    [
      GameScraper,
      MovieScraper,
      TvScraper
    ]
  end
end
