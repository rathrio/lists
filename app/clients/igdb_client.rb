class IgdbClient
  include HTTParty
  headers 'X-Mashape-Key' => ENV['IGDB_API_KEY']
  base_uri 'https://igdbcom-internet-game-database-v1.p.mashape.com'
  default_params fields: '*'

  def search(query)
    self.class.get("/games/", query: { search: query })
  end

  def genre(id)
    self.class.get("/genres/#{id}", query: { fields: 'name' })
  end
end
