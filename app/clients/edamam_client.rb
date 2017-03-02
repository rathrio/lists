class EdamamClient
  include HTTParty
  base_uri 'https://api.edamam.com'
  default_params app_id: ENV['EDAMAM_API_ID'], app_key: ENV['EDAMAM_API_KEY']

  def search(query)
    params = { q: query }
    self.class.get("/search", query: params)
  end
end
