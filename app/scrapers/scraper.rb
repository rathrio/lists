# Include this module to a class to make it behave like a scraper.
module Scraper

  # @return [Array<Scraper>] list of classes that include this module.
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

  # Method called to perform actual scraping. No need to override this one.
  # Override the scrape_<attribute> template methods.
  #
  # @return [Array<Hash>] list of result Hashes that can be passed as an
  #   argument to Item.create_from(result) or Item#update_from(result).
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

  # @return [Array] an Array of objects most likely retrieved via an API call.
  #   Each element will get passed to the scraper template methods in order to
  #   extract the desired data.
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
