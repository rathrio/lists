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

  test 'Can put arbitrary content in result' do

    # Add two custom result attributes
    dummy_class_definition = Class.new(DummyScraper) do
      scrape_attribute :foo do |result|
        "foo"
      end

      scrape_attribute :bar do |result|
        "bar"
      end

    end
    Object.const_set("FoobarScraper", dummy_class_definition)
    results = FoobarScraper.new(query: "30").scrape
    result = results.first
    assert("foo", result[:foo])
    assert("bar", result[:bar])
  end

end
