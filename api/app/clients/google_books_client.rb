class GoogleBooksClient
  include HTTParty
  base_uri "https://www.googleapis.com/books/v1"
  default_params key: ENV["GOOGLE_BOOKS_API_KEY"]

  def search(query, filter_values:)
    query = "intitle:#{query}"

    # Google Books API supports title searches like "The city & the city 2009"
    filter_values.each do |filter_value|
      filter = filter_value["filter"]
      value = filter_value["value"]

      case filter
      when "year"
        year = value.to_i
        query += " #{year}"
      end
    end

    params = { q: query }
    self.class.get("/volumes", query: params)
  end
end
