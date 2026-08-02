# frozen_string_literal: true

class JellyfinClient
  include HTTParty
  base_uri ENV.fetch("JELLYFIN_HOST")
  default_timeout 10

  class Error < StandardError; end

  def initialize
    @api_key = ENV.fetch("JELLYFIN_API_KEY")
    @user_id = ENV.fetch("JELLYFIN_USER_ID")
  end

  # @return [Array<Hash>] every played movie, with ProviderIds and UserData
  def played_movies
    items(IncludeItemTypes: "Movie", Filters: "IsPlayed", Fields: "ProviderIds")
  end

  # @return [Array<Hash>] every series, with ProviderIds, Status and UserData
  def series
    items(IncludeItemTypes: "Series", Fields: "ProviderIds")
  end

  # The most recently played episode of a series — used to date when a
  # series was finished, since a series' UserData carries no LastPlayedDate.
  #
  # @return [Hash, nil]
  def newest_played_episode(series_id)
    items(
      IncludeItemTypes: "Episode",
      ParentId: series_id,
      Filters: "IsPlayed",
      SortBy: "DatePlayed",
      SortOrder: "Descending",
      Limit: 1
    ).first
  end

  private

  def items(query)
    response = self.class.get(
      "/Items",
      query: { userId: @user_id, Recursive: true }.merge(query),
      headers: { "Authorization" => "MediaBrowser Token=#{@api_key}" }
    )
    raise Error, "Jellyfin /Items failed (#{response.code})" unless response.success?

    response.parsed_response["Items"] || []
  end
end
