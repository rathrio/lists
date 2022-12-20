# frozen_string_literal: true

require "test_helper"
require "minitest/mock"

class MovieScraperTest < ActiveSupport::TestCase
  test "#scrape scrapes backdrop image" do
    scraper = MovieScraper.new(query: "police story")

    scraper.stub(
      :search_results,
      [
        {
          "adult" => false,
          "backdrop_path" => "/eDtsTxALld2gPw9lO1hQIJXqMHu.jpg",
          "genre_ids" => [12, 28, 53],
          "id" => 954,
          "original_language" => "en",
          "original_title" => "Mission: Impossible",
          "overview" => "When Ethan Hunt, the leader of a crack espionage team whose perilous operation has gone awry with no explanation, discovers that a mole has penetrated the CIA, he's surprised to learn that he's the No. 1 suspect. To clear his name, Hunt now must ferret out the real double agent and, in the process, even the score.",
          "popularity" => 35.872,
          "poster_path" => "/pyQqxuDYmkyNnjC131bmt1bzShW.jpg",
          "release_date" => "1996-05-22",
          "title" => "Mission: Impossible",
          "video" => false,
          "vote_average" => 6.9,
          "vote_count" => 7397,
        },
        {
          "adult" => false,
          "backdrop_path" => "/aw4FOsWr2FY373nKSxbpNi3fz4F.jpg",
          "genre_ids" => [28, 12],
          "id" => 353081,
          "original_language" => "en",
          "original_title" => "Mission: Impossible - Fallout",
          "overview" => "When an IMF mission ends badly, the world is faced with dire consequences. As Ethan Hunt takes it upon himself to fulfill his original briefing, the CIA begin to question his loyalty and his motives. The IMF team find themselves in a race against time, hunted by assassins while trying to prevent a global catastrophe.",
          "popularity" => 51.033,
          "poster_path" => "/AkJQpZp9WoNdj7pLYSj1L0RcMMN.jpg",
          "release_date" => "2018-07-13",
          "title" => "Mission: Impossible - Fallout",
          "video" => false,
          "vote_average" => 7.4,
          "vote_count" => 6891,
        },
      ]
    ) do
      results = scraper.scrape
      refute_nil results.first.fetch(:remote_backdrop_image_url), "backdrop image must be present"
      refute_nil results.second.fetch(:remote_backdrop_image_url), "backdrop image must be present"
    end
  end

  test "#scrape returns nil in original_name if it equals name" do
    scraper = MovieScraper.new(query: "police story")

    scraper.stub(
      :search_results,
      [
        {
          "adult" => false,
          "backdrop_path" => nil,
          "genre_ids" => [80, 18, 10_770],
          "id" => 128_008,
          "original_language" => "en",
          "original_title" => "Some chinese name",
          "overview" => "Thriller/Drama about LAPD detectives tracking down two serial killers who are murdering hookers.",
          "popularity" => 5.706,
          "poster_path" => "/tWoffNyRfpDHVMCCrheVWSlPHK3.jpg",
          "release_date" => "1987-05-03",
          "title" => "Police Story: The Freeway Killings",
          "video" => false,
          "vote_average" => 5,
          "vote_count" => 1,
        },
        {
          "adult" => false,
          "backdrop_path" => nil,
          "genre_ids" => [28, 53, 10_770],
          "id" => 594_707,
          "original_language" => "en",
          "original_title" => "Police Story: Burnout",
          "overview" => "A veteran vice cop (Wagner) has a hard time dealing with her partner's suicide.",
          "popularity" => 1.34,
          "poster_path" => "/vpXgo4SztT8ySEOP00QrpXk88U0.jpg",
          "release_date" => "1988-11-26",
          "title" => "Police Story: Burnout",
          "video" => false,
          "vote_average" => 0,
          "vote_count" => 0,
        },
      ]
    ) do
      results = scraper.scrape

      result_with_distinct_original_name = results[0]
      assert_equal("Some chinese name", result_with_distinct_original_name.fetch(:original_name))

      result_with_same_original_name = results[1]
      assert_nil result_with_same_original_name.fetch(:original_name)
    end
  end
end
