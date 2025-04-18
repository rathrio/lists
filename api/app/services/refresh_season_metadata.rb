# frozen_string_literal: true

class RefreshSeasonMetadata
  def self.run(user)
    tv_list = user.lists.find_by(scraper: "TvScraper")
    return [] if tv_list.nil?

    tv_shows = tv_list.items.doing
    tv_shows.each do |tv_show|
      refresh_season_metadata(tv_show)
    end
  end

  def self.refresh_season_metadata(tv_show)
    tmdb_id = tv_show.metadata["tmdb_id"]
    return if tmdb_id.blank?

    moviedb_client = MoviedbClient.new
    metadata = moviedb_client.tv_show_season_metadata(tmdb_id)
    return unless metadata["seasons"]

    tv_show.update!(metadata: tv_show.metadata.merge(metadata))
  end
end
