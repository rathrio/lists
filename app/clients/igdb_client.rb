class IgdbClient
  include HTTParty
  headers 'user-key' => ENV['IGDB_API_KEY']
  base_uri 'https://api-2445582011268.apicast.io'
  default_params fields: '*'

  def search(query)
    self.class.get("/games/", query: { search: query, expand: "genres" })
  end

  def genre(ids)
    return [] if ids.blank?
    self.class.get("/genres/#{ids.join(',')}", query: { fields: 'name' })
  end
end
