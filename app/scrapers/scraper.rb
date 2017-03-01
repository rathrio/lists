# Including this module makes a class behave like a scraper.
#
# In order to define a new scraper, the following 3 steps would be required:
#   1. Write a new class that includes the Scraper module.
#   2. Define on which client(s) the Scraper _relies on_ and how it processes that _resource_.
#   3. Define which attributes- and how they should be scraped. 
#
# @example Example scraper definition
#
#   # in app/scrapers/action_movie_scraper.rb
#
#   class ActionMovieScraper
#     include Scraper
#
#     rely_on :action_movie_api do |query|
#       action_movie_api.search(query) # => e.g. [{ title: 'foo' }, { title: 'bar' }]
#     end
#
#     scrape_attribute :name do |result|
#       result[:title]
#     end
#
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
#
module Scraper

  DEFAULT_ATTRIBUTES = [
    :name,
    :description,
    :image,
    :date,
    :tags
  ].freeze

  # @return [Array<Scraper>] list of classes that include this module.
  def self.all
    @scrapers ||= []
  end

  attr_accessor :query

  def initialize(query:)
    @query = query
  end
 
  module Makros

    # Fetch the results provided by the target client type. The result
    # Is built by applying the given block on the client's output.
    # Moreover, it defines an accessor to an instance of type client. 
    # This can be used by the scraper instance
    # builds resuls object
    # @param client [Class] class name of target client.
    # @param block [Proc] defines how result object should be processed
    def rely_on(client, &block)

      if block.nil?
        raise NotImplementedError, <<~EOS
        Implement #search_results and make it return an array or results.
        EOS
      end

      # define a client singleton getter
      # @example
      #   rely_on :moviedb_client
      #   will define a getter #moviedb_cient
      #   that returns a singleton of MoviedbClient
      self.define_singleton_method client do
        klass = client.to_s.classify.constantize
        @client ||= klass.new
      end

      self.class_eval do
        define_method :search_results do
          block.call(query)
        end
      end
    end

    def scrape_attribute(attribute_name, &block)
      self.class_eval do
        method_name = "scrape_#{attribute_name.to_s}".to_sym
        define_method(method_name) do |arg|
          block.call(arg)
        end
      end
    end
  end

  def self.included(scraper)
    scraper.extend Makros
    DEFAULT_ATTRIBUTES.each do |default_attribute|
      method_name = "scrape_#{default_attribute.to_s}".to_sym
      define_method(method_name) do
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
    end
    all << scraper
  end

  # Method called to perform actual scraping. No need to override this one.
  # Override the scrape_<attribute> template methods.
  #
  # @return [Array<Hash>] list of result Hashes that can be passed as an
  #   argument to Item.create_from(result) or Item#update_from(result).
  def scrape
    scraper_methods = methods.select { |m| m.to_s.include? "scrape_" }
    search_results.map do |result|
      result = scraper_methods.map do |m|
        key = m.to_s.gsub("scrape_", "").to_sym
        [key, send(m, result)]
      end
      result.to_h
    end
  end

end
