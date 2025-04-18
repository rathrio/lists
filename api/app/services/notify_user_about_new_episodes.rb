# frozen_string_literal: true

class NotifyUserAboutNewEpisodes
  def self.run(user)
    tv_shows_with_new_episodes(user).each do |tv_show|
      metadata = tv_show.metadata["last_episode_to_air"]
      season_number = metadata["season_number"]
      episode_number = metadata["episode_number"]
      next unless season_number && episode_number

      # Idempotency key to avoid spamming notifications
      key = "#{user.id}-#{tv_show.id}-#{season_number}-#{episode_number}"
      next if Notification.exists?(key:)

      body = <<~BODY
        Episode #{episode_number} of #{tv_show.name} Season #{season_number} should be out.

        Cheers
        https://lists.rathr.io
      BODY

      notification = user.notifications.create!(
        key:,
        subject: "#{tv_show.name} has new episodes!",
        body:,
      )

      send_email(notification)
    end
  end

  # @return [Enumerable<Item>]
  def self.tv_shows_with_new_episodes(user)
    tv_list = user.lists.find_by(scraper: "TvScraper")
    return [] if tv_list.nil?

    tv_shows = tv_list.items.doing
    today = Time.now.strftime("%Y-%m-%d")

    tv_shows.select do |tv_show|
      tv_show.metadata["last_episode_to_air"]&.dig("air_date")&.<= today
    end
  end

  def self.send_email(notification)
    NotificationMailer.with(notification:).email.deliver_now
    notification.update!(email_status: :success)
  rescue StandardError => e
    Rails.logger.error(
      "Something went wrong while attempting to send notification with ID #{notification.id}: #{e}"
    )
    notification.update!(email_status: :error)
  end
end
