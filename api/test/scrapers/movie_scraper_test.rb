# frozen_string_literal: true

require 'test_helper'
require 'minitest/mock'

class MovieScraperTest < ActiveSupport::TestCase
  test '#scrape returns nil in original_name if it equals name' do
    scraper = MovieScraper.new(query: 'police story')

    scraper.stub(
      :search_results,
      [
        {
          'adult' => false,
          'backdrop_path' => nil,
          'genre_ids' => [80, 18, 10_770],
          'id' => 128_008,
          'original_language' => 'en',
          'original_title' => 'Some chinese name',
          'overview' =>
            'Thriller/Drama about LAPD detectives tracking down two serial killers who are murdering hookers.',
          'popularity' => 5.706,
          'poster_path' => '/tWoffNyRfpDHVMCCrheVWSlPHK3.jpg',
          'release_date' => '1987-05-03',
          'title' => 'Police Story: The Freeway Killings',
          'video' => false,
          'vote_average' => 5,
          'vote_count' => 1
        },
        {
          'adult' => false,
          'backdrop_path' => nil,
          'genre_ids' => [28, 53, 10_770],
          'id' => 594_707,
          'original_language' => 'en',
          'original_title' => 'Police Story: Burnout',
          'overview' =>
            "A veteran vice cop (Wagner) has a hard time dealing with her partner's suicide.",
          'popularity' => 1.34,
          'poster_path' => '/vpXgo4SztT8ySEOP00QrpXk88U0.jpg',
          'release_date' => '1988-11-26',
          'title' => 'Police Story: Burnout',
          'video' => false,
          'vote_average' => 0,
          'vote_count' => 0
        }
      ]
    ) do
      results = scraper.scrape

      result_with_distinct_original_name = results[0]
      assert_equal('Some chinese name', result_with_distinct_original_name.fetch(:original_name))

      result_with_same_original_name = results[1]
      assert_nil result_with_same_original_name.fetch(:original_name)
    end
  end
end
