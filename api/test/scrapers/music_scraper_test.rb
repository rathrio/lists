# frozen_string_literal: true

require "test_helper"

class MusicScraperTest < ActiveSupport::TestCase
  test "#scrape formats name as Artist - Album" do
    scraper = MusicScraper.new(query: "Radiohead - OK Computer")

    scraper.stub(:search_results, [musicbrainz_result]) do
      result = scraper.scrape.first

      assert_equal "Radiohead - OK Computer", result[:name]
    end
  end

  test "#scrape extracts release date" do
    scraper = MusicScraper.new(query: "Radiohead - OK Computer")

    scraper.stub(:search_results, [musicbrainz_result]) do
      result = scraper.scrape.first

      assert_equal Date.new(1997, 6, 16), result[:date]
    end
  end

  test "#scrape handles year-only dates" do
    scraper = MusicScraper.new(query: "test")
    result_with_year_only = musicbrainz_result.merge("date" => "1997")

    scraper.stub(:search_results, [result_with_year_only]) do
      result = scraper.scrape.first

      assert_equal Date.new(1997, 1, 1), result[:date]
    end
  end

  test "#scrape builds cover art URL from MBID" do
    scraper = MusicScraper.new(query: "test")

    scraper.stub(:search_results, [musicbrainz_result]) do
      result = scraper.scrape.first

      assert_equal "https://coverartarchive.org/release/b1a9c0e9-d987-4042-ae91-78d6a3267d69/front-500",
                   result[:remote_image_url]
    end
  end

  test "#scrape stores metadata" do
    scraper = MusicScraper.new(query: "test")

    scraper.stub(:search_results, [musicbrainz_result]) do
      result = scraper.scrape.first

      assert_equal "b1a9c0e9-d987-4042-ae91-78d6a3267d69", result[:metadata][:mbid]
      assert_equal "Radiohead", result[:metadata][:artist]
      assert_equal "GB", result[:metadata][:country]
    end
  end

  test ".human_status returns music-specific status names" do
    assert_equal "To Listen", MusicScraper.human_status(:todo)
    assert_equal "Listening", MusicScraper.human_status(:doing)
    assert_equal "Listened", MusicScraper.human_status(:done)
  end

  private

  def musicbrainz_result
    {
      "id" => "b1a9c0e9-d987-4042-ae91-78d6a3267d69",
      "title" => "OK Computer",
      "date" => "1997-06-16",
      "country" => "GB",
      "status" => "Official",
      "barcode" => "724385522925",
      "artist-credit" => [
        {
          "name" => "Radiohead",
          "artist" => {
            "id" => "a74b1b7f-71a5-4011-9441-d0b5e4122711",
            "name" => "Radiohead"
          }
        }
      ],
      "label-info" => [
        {
          "label" => {
            "name" => "Parlophone"
          }
        }
      ]
    }
  end
end
