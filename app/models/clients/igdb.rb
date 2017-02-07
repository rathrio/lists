module Clients
  class Igdb
    include HTTParty
    headers 'X-Mashape-Key' => ENV['IGDB_API_KEY']
    base_uri 'https://igdbcom-internet-game-database-v1.p.mashape.com'
    default_params fields: '*'

    def initialize(query: '')
      @query = query
    end

    def search
      self.class.get("/games/?search=#{@query}")
    end
  end
end
