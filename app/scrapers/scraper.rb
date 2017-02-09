module Scraper
  def self.all
    @scrapers ||= []
  end

  def self.included(scraper)
    all << scraper
  end

  attr_reader :query

  def initialize(query:)
    @query = query
  end

  def scrape
    raise NotImplementedError
  end
end
