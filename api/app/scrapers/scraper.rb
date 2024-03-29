# frozen_string_literal: true

# Include this module make a class behave like a scraper.
#
# There are a bunch of template methods you can override to tweak the scraping
# behaviour:
#
#   * #search_results: an array of results, most likely from a remote API call
#   * #scrape_<attribute>(result): extracts <attribute> from one result
#
# @example Example scraper definition
#
#   # in app/scrapers/action_movie_scraper.rb
#
#   class ActionMovieScraper
#     include Scraper
#
#     def search_results
#       action_movie_api.search(query) # => e.g. [{ title: 'foo' }, { title: 'bar' }]
#     end
#
#     def scrape_name(result)
#       result[:title]
#     end
#   end
#
# @example Update an item with the first result of ActionMovieScraper results
#
#   scraper = ActionMovieScraper.new(query: 'lethal weapon')
#   result = scraper.scrape.first # => { name: 'lethal weapon 2: reloaded' }
#
#   item = Item.create # ...
#   item.update_from(result)
#   item.name # => 'lethal weapon 2: reloaded'
module Scraper
  module ClassMethods
    def human_status_names
      @human_status_names ||= {
        todo: "Todo",
        doing: "Doing",
        done: "Done",
      }
    end

    # @return [String] media specific status name, e.g. "Watching" for the
    #   status "doing" if this scraper scrapes movie data. Override
    #   .human_status_names in scraper descendants.
    def human_status(status)
      human_status_names.fetch(status.to_sym.downcase)
    end
  end

  # @return [Array<Scraper>] list of classes that include this module.
  def self.all
    @scrapers ||= []
  end

  def self.included(scraper)
    all << scraper

    scraper.extend(ClassMethods)
  end

  # @return [String]
  attr_reader :query

  # @return [Array<Hash>]
  attr_reader :filter_values

  def initialize(query:, filter_values: [])
    @query = query
    @filter_values = filter_values
  end

  # Method called to perform actual scraping. No need to override this one.
  # Override the scrape_<attribute> template methods.
  #
  # @return [Array<Hash>] list of result Hashes that can be passed as an
  #   argument to Item#update_from(result).
  def scrape
    search_results.map do |result|
      name = scrape_name(result)
      original_name = scrape_original_name(result)

      {
        name: name,
        original_name: name == original_name ? nil : original_name,
        description: scrape_description(result),
        remote_image_url: scrape_image(result),
        remote_backdrop_image_url: scrape_backdrop_image(result),
        date: scrape_date(result),
        links: scrape_links(result),
        tags: scrape_tags(result),
        language: scrape_language(result),
        metadata: scrape_metadata(result),
      }
    end.select { |result| result[:remote_image_url].present? }
  end

  # @return [Array] an Array of objects most likely retrieved via an API call.
  #   Each element will get passed to the scraper template methods in order to
  #   extract the desired data.
  def search_results
    raise NotImplementedError, <<~EOS
            Implement #search_results and make it return an array or results.
          EOS
  end

  # @param result [Hash]
  # @return [String]
  def scrape_name(result)
    raise NotImplementedError, <<~EOS
            Implement #scrape_name(result) and extract the value from result that
            correspond with the name of an item.

            result is one element of whatever #search_results returns.

            Example:

            # Assuming #search_results returns an array of hashes with key :title
            def scrape_name(result)
              result[:title]
            end
          EOS
  end

  # @param result [Hash]
  # @return [String, nil]
  def scrape_original_name(result)
  end

  # @param result [Hash]
  # @return [String, nil]
  def scrape_description(result)
  end

  # @param result [Hash]
  # @return [String, nil] a remote URL to a cover image
  def scrape_image(result)
  end

  # @param result [Hash]
  # @return [String, nil] a remote URL to a backdrop image
  def scrape_backdrop_image(result)
  end

  # @param result [Hash]
  # @return [Date, nil]
  def scrape_date(result)
  end

  # @param result [Hash]
  # @return [Array<Link>] list of links extracted from result.
  def scrape_links(result)
    []
  end

  # @param result [Hash]
  # @return [Array<String>]
  def scrape_tags(result)
    []
  end

  # @param result [Hash]
  # @return [String, nil] The original language as a two letter language code (ISO 639-1),
  #   nil if no language can be scraped.
  def scrape_language(result)
  end

  # @param result [Hash]
  def scrape_metadata(result)
    {}
  end
end
