class IgdbClient
  include HTTParty
  headers 'X-Mashape-Key' => ENV['IGDB_API_KEY']
  base_uri 'https://igdbcom-internet-game-database-v1.p.mashape.com'
  default_params fields: '*'

  def search(query)
    self.class.get("/games/", query: { search: query })
  end

  def genre(ids)
    return [] if ids.blank?
    self.class.get("/genres/#{ids.join(',')}", query: { fields: 'name' })
  end
end
