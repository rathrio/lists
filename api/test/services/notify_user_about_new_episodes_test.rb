# frozen_string_literal: true

require "test_helper"

class NotifyUserAboutNewEpisodesTest < ActionDispatch::IntegrationTest
  test "does not notify if nothing no TV shows are being watched" do
    list = create(:list, name: "TV", scraper: "TvScraper")
    assert_empty list.items

    assert_equal 0, Notification.count
    assert_emails 0 do
      NotifyUserAboutNewEpisodes.run(list.user)
    end
  end

  test "notify if new episodes are present" do
    list = create(:list, name: "TV", scraper: "TvScraper")
    show = create(:item, list:, status: :doing)
    metadata = {
      "last_episode_to_air" => {
        "air_date" => "2013-09-29",
        "season_number" => 5,
        "episode_number" => 16,
      },
    }

    show.update!(metadata:)

    assert_equal 0, Notification.count

    assert_emails 1 do
      NotifyUserAboutNewEpisodes.run(list.user)
    end

    assert_equal 1, Notification.count
    notification = Notification.last
    assert_match(/Episode 16/, notification.body)

    delivery = ActionMailer::Base.deliveries.last
    assert_match(/Episode 16/, delivery.body.raw_source)
  end
end
