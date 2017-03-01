require 'test_helper'

class ScraperTest < ActiveSupport::TestCase

  test 'Can scrape data' do
    results = DummyScraper.new(query: "30").scrape
    result = results.first
    assert("nils", result[:name])
    assert("Name of this entity: nils", result[:description])
    assert("37", result[:date])
    assert("some_fancy_nils_image.jpg", result[:date])
    assert("nude", result[:tags].first)
  end

end
