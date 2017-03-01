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
module Scraper

  DEFAULT_SCRAPER_ATTRIBUTES = [
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

  # Remember the user query and maintain a list of translations
  # between attribute_names and their aliases.
  #
  # @example
  #   TvScraper.new(query: "The Walking Dead")
  #
  # @param query [String] query that should be
  #   send to the specified client(s).
  def initialize(query:)
    @query = query
    @alias_names = {
      :image => :remote_image_url
    }
  end

  # Append a new alias to the list of all aliases.
  #
  # @info: This method should only be used inside the Scraper module.
  #
  # @param name [Symbol]
  # @param alias_name [Symbol]
  def append_alias_name(name, alias_name)
    @alias_names[name] = alias_name
  end

  # Defines the DSL elements used to specify a scraper.
  # The following elements are available:
  #   rely_on: defines the used client and
  #     how the query is processed
  #   scraper_attribute: defines which attributes the
  #     scraper results contains and how they are computed using the client's result.
  module Macros

    # Defines dynamicall how a given query an a given client
    # should be performed.
    #
    # After invoking this method, the scraper instance can
    # reference a singleton instance of the specified client.
    #
    # @info: calling this method defines a instance method
    #   #search_result. This method is used by the #scape method
    #   to further process - by the client - fetched results.
    #
    # @example
    #   class FoobarScraper
    #     rely_on :imdb_client do |query|
    #
    #       # this invocation should return an array.
    #       imdb_client.search(query)
    #     end
    #   end
    #
    # @param client [Symbol] class name (as symbol) of target client.
    # @param block [Proc] defines how result object should be
    #   processed when sending the query message to the specified client.
    def rely_on(client, &block)

      if block.nil?
        raise NotImplementedError, <<~EOS
        Implement #search_results and make it return an array or results.
        EOS
      end

      # define a client singleton getter. This instance can be used
      # in instance scope.
      #
      # @example
      #   rely_on :moviedb_client do |query|
      #     # do somethin here
      #   end
      #   this call will define a getter #moviedb_client
      #   which returns a singleton instance of type MoviedbClient
      self.define_singleton_method client do
        klass = client.to_s.classify.constantize
        @client ||= klass.new
      end

      # Defines a instance method #search_results that contains the output
      #   received when sending the query message to the specified client.
      #
      # @info: This class is never directly called but is used by the scrape method.
      #
      # @return [Array] an Array of objects most likely retrieved via an API call.
      #   Each element will get passed to the scraper template methods in order to
      #   extract the desired data.
      self.class_eval do
        define_method :search_results do
          block.call(query)
        end
      end
    end

    # Dynamically define which attributes the scraper result
    # contains and how they are compute.
    #
    # This method dynamically define a scraper method that
    # returns the result when apply the given block.
    #
    # @example
    #   class FoobarScraper
    #     scrape_attribute :name do |result|
    #       result[:name]
    #     end
    #
    #     # define a description text scraper called scrape_description.
    #     # The result of this scraper template method can be found
    #     # in the result object and is accessed via the given alias_name (:info)
    #     scrape_attribute :description, :info do |result|
    #       "Info text: #{result[:description]}"
    #     end
    #   end
    #
    # @param attribute_name [Symbol] Defines the name in the result object.
    # @param attribute_alias [Symbol] the key that is used to access
    #   the value in the result object that was computed by the definition
    #   of this scrape attribute. This is an optional argument and by default nil.
    #   In case  this element is not specified, the result object's key has the same name
    #   as the scraper.
    # @param block [Proc] defines how the scraper is computed using the client's result.
    def scrape_attribute(attribute_name, alias_name=nil, &block)
      append_alias_name(attribute_name, alias_name) unless alias_name.nil?
      self.class_eval do
        method_name = "scrape_#{attribute_name.to_s}".to_sym
        define_method(method_name) do |arg|
          block.call(arg)
        end
      end
    end
  end

  # First, the class macros are defined to mimic the scraper DSL,
  # then some default scraper instance method sare defined
  # and lastely, the current scraper is added to the list of all available scrapers.
  #
  # @param scraper [Class] class that implements this scraper module.
  def self.included(scraper)
    scraper.extend Macros

    # define default scraper methods
    DEFAULT_SCRAPER_ATTRIBUTES.each do |default_attribute|
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
  # @info: This method can be used to obtain the scraper results.
  #
  # @return [Array<Hash>] list of result Hashes that can be passed as an
  #   argument to Item.create_from(result) or Item#update_from(result).
  def scrape
    scraper_methods = methods.select { |m| m.to_s.include? "scrape_" }
    search_results.map do |result|
      result = scraper_methods.map do |m|
        key = m.to_s.gsub("scrape_", "").to_sym
        alias_key = @alias_names[key]
        key = alias_key.nil? ? key : alias_key
        [key, send(m, result)]
      end
      result.to_h
    end
  end

end
