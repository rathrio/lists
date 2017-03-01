# @example
#   class Foobar
#     def name
#       "c_name"
#     end
#   end
#  
#   class B
#     include NewScraper
#  
#     rely_on :foobar do
#       val = "fetched name: " + foobar.name
#       puts val
#       [{name: "foobar"}]
#     end
#  
#     scrape_attribute :foo do |res|
#       res[:name]
#     end
#   end
module Scraper

  # @return [Array<Scraper>] list of classes that include this module.
  def self.all
    @scrapers ||= []
  end

  attr_accessor :query

  def initialize(query:)
    @query = query
  end
 
  module Makros

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
# module Scraper
# 
#   # @return [Array<Scraper>] list of classes that include this module.
#   def self.all
#     @scrapers ||= []
#   end
# 
#   def self.included(scraper)
#     all << scraper
#   end
# 
#   attr_reader :query
# 
#   def initialize(query:)
#     @query = query
#   end
# 
#   # Method called to perform actual scraping. No need to override this one.
#   # Override the scrape_<attribute> template methods.
#   #
#   # @return [Array<Hash>] list of result Hashes that can be passed as an
#   #   argument to Item.create_from(result) or Item#update_from(result).
#   def scrape
#     search_results.map do |result|
#       {
#         name: scrape_name(result),
#         description: scrape_description(result),
#         remote_image_url: scrape_image(result),
#         date: scrape_date(result),
#         links: scrape_links(result),
#         tags: scrape_tags(result)
#       }
#     end
#   end
# 
#   # @return [Array] an Array of objects most likely retrieved via an API call.
#   #   Each element will get passed to the scraper template methods in order to
#   #   extract the desired data.
#   def search_results
#     raise NotImplementedError, <<~EOS
#       Implement #search_results and make it return an array or results.
#     EOS
#   end
# 
#   def scrape_name(result)
#     raise NotImplementedError, <<~EOS
#       Implement #scrape_name(result) and extract the value from result that
#       correspond with the name of an item.
# 
#       result is one element of whatever #search_results returns.
# 
#       Example:
# 
#       # Assuming #search_results returns an array of hashes with key :title
#       def scrape_name(result)
#         result[:title]
#       end
#     EOS
#   end
# 
#   def scrape_description(result)
#   end
# 
#   def scrape_image(result)
#   end
# 
#   def scrape_date(result)
#   end
# 
#   def scrape_links(result)
#     []
#   end
# 
#   def scrape_tags(result)
#     []
#   end
# end
