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
    search_results.map do |result|
      {
        name: scrape_name(result),
        description: scrape_description(result),
        remote_image_url: scrape_image(result),
        date: scrape_date(result),
        links: scrape_links(result),
        tags: scrape_tags(result)
      }
    end
  end

  def search_results
    []
  end

  def scrape_name(result)
  end

  def scrape_description(result)
  end

  def scrape_image(result)
  end

  def scrape_date(result)
  end

  def scrape_links(result)
    []
  end

  def scrape_tags(result)
    []
  end
end
