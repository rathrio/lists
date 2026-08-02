# frozen_string_literal: true

# Flips lists items to done once they've actually been watched in Jellyfin,
# matched by TMDB id.
#
# Promote-only: todo/doing → done, never the other way — a Jellyfin library
# rescan or ghost-entry cleanup can reset played state, and that must not
# undo anything set by hand. Items already done are skipped outright.
#
# Runs dry (log-only) unless JELLYFIN_WATCH_SYNC_ENABLED=true, so the first
# run after a deploy can be reviewed before anything is written.
class JellyfinWatchSyncJob < ApplicationJob
  queue_as :default

  def perform(dry_run: !ENV["JELLYFIN_WATCH_SYNC_ENABLED"].to_s.casecmp?("true"))
    @dry_run = dry_run
    @client = JellyfinClient.new
    user = User.find(ENV.fetch("LISTS_SYNC_USER_ID"))

    sync_movies(user)
    sync_series(user)
  end

  private

  def sync_movies(user)
    items = matchable_items(user, "MovieScraper")
    return if items.empty?

    matched = 0
    @client.played_movies.each do |movie|
      candidates = items[movie.dig("ProviderIds", "Tmdb").to_s]
      next if candidates.blank?

      matched += candidates.size
      played_at = movie.dig("UserData", "LastPlayedDate")
      candidates.each { |item| promote(item, movie["Name"], played_at) }
    end

    log("#{items.values.sum(&:size)} matchable movie item(s), #{matched} watched in Jellyfin")
  end

  def sync_series(user)
    items = matchable_items(user, "TvScraper")
    return if items.empty?

    matched = 0
    @client.series.each do |series|
      # A Continuing series with nothing unplayed is caught up, not done.
      next unless series["Status"] == "Ended"
      next unless series.dig("UserData", "UnplayedItemCount")&.zero?

      candidates = items[series.dig("ProviderIds", "Tmdb").to_s]
      next if candidates.blank?

      matched += candidates.size
      played_at = @client
                  .newest_played_episode(series["Id"])
                  &.dig("UserData", "LastPlayedDate")
      candidates.each { |item| promote(item, series["Name"], played_at) }
    end

    log("#{items.values.sum(&:size)} matchable TV item(s), #{matched} finished in Jellyfin")
  end

  # The user's not-yet-done items that carry a TMDB id, keyed by that id.
  # Keys are strings because Jellyfin's Tmdb provider id is a string.
  #
  # @return [Hash{String => Array<Item>}]
  def matchable_items(user, scraper)
    list = user.lists.find_by(scraper:)
    return {} if list.nil?

    list.items
        .where.not(status: Item.statuses[:done])
        .select { |item| item.tmdb_id.present? }
        .group_by { |item| item.tmdb_id.to_s }
  end

  def promote(item, jellyfin_name, played_at)
    # Date the journal entry from Jellyfin, not from when the sync ran.
    first_done_at = item.first_done_at || played_at&.to_date || Date.today

    if @dry_run
      log("[DRY RUN] Would mark ##{item.id} \"#{item.name}\" done " \
          "(watched #{first_done_at}, Jellyfin: \"#{jellyfin_name}\")")
      return
    end

    item.update!(status: :done, first_done_at:)
    log("Marked ##{item.id} \"#{item.name}\" done (watched #{first_done_at})")
  end

  def log(message)
    Rails.logger.info("[JellyfinWatchSync] #{message}")
  end
end
