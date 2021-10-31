class GoogleBooksClient
  include HTTParty
  base_uri 'https://www.googleapis.com/books/v1'
  default_params key: ENV['GOOGLE_BOOKS_API_KEY']

  def search(query)
    params = { q: query }
    self.class.get("/volumes", query: params)
  end
end
