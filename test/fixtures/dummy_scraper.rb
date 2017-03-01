class DummyScraper
  include Scraper

  rely_on :dummy_client do |query|
    dummy_client.search(query)
  end

  scrape_attribute :name do |result|
    result[:name]
  end

  scrape_attribute :description do |result|
    "Name of entity: #{result[:name]}"
  end

  scrape_attribute :date do |result|
    result[:age]
  end

  scrape_attribute :image do |result|
    "some_fancy_#{result[:name]}_image.jpg"
  end
  
  scrape_attribute :tags do |result|
    ["nude"]
  end

end
