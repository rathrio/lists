# frozen_string_literal: true

class RefreshSeasonMetadataJob < ApplicationJob
  queue_as :default

  def perform
    user = User.find(1)

    tv_list = user.lists.find_by(scraper: "TvScraper")
    return [] if tv_list.nil?

    tv_shows = tv_list.items
    tv_shows.each do |tv_show|
      refresh_season_metadata(tv_show)
    end
  end

  private

  def refresh_season_metadata(tv_show)
    tmdb_id = tv_show.metadata["tmdb_id"]
    return if tmdb_id.blank?

    moviedb_client = MoviedbClient.new
    metadata = moviedb_client.tv_show_season_metadata(tmdb_id)
    return unless metadata["seasons"]

    tv_show.update!(metadata: tv_show.metadata.merge(metadata))
  end
end
