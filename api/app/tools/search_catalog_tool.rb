# frozen_string_literal: true

class SearchCatalogTool < McpTool
  LIMIT = 5
  DESCRIPTION_LENGTH = 300

  tool_name "search_catalog"
  description "Searches the online catalog behind a list (TMDB for movies and TV, " \
              "IGDB for games, Google Books, MusicBrainz) for titles to add. Returns " \
              "up to #{LIMIT} results; to add one, pass its exact name and year to " \
              "add_item. Compare year, original title and description to pick the " \
              "right one, and ask the user when it's ambiguous. in_library flags " \
              "titles the user already has."
  input_schema(
    properties: {
      list: FILTER_PROPERTIES[:list],
      query: {
        type: "string",
        description: "Title to search for. For music: \"Artist - Album\".",
      },
      year: {
        type: "integer",
        description: "Release year, to tell remakes and namesakes apart.",
      },
    },
    required: %w[list query],
  )
  annotations(
    read_only_hint: true,
    destructive_hint: false,
    idempotent_hint: true,
    open_world_hint: true,
  )

  def self.run(user, list:, query:, year: nil)
    list = find_list(user, list)
    if list.default_scraper.nil?
      raise InvalidArgument, "#{list.name} has no catalog to search. " \
                             "Use add_item with custom details instead."
    end

    results = search(list, query:, year:)
    return { results: [], hint: no_match_hint(year) } if results.empty?

    { results: results.map { |result| summarize_result(list, result) } }
  end

  # Scraper results for query, as shown by search_catalog.
  #
  # @return [Array<Hash>] see Scraper#scrape
  def self.search(list, query:, year: nil)
    filter_values = year ? [{ "filter" => "year", "value" => year }] : []
    list.default_scraper.new(query:, filter_values:).scrape(limit: LIMIT)
  end

  def self.summarize_result(list, result)
    existing = find_existing(list, name: result[:name], date: result[:date],
                                   metadata: result[:metadata])
    {
      name: result[:name],
      original_name: result[:original_name],
      year: result[:date]&.year,
      release_date: result[:date],
      language: result[:language],
      tags: result[:tags].presence,
      description: result[:description]&.truncate(DESCRIPTION_LENGTH).presence,
      image_url: result[:remote_image_url],
      in_library: existing && {
        id: existing.id,
        status: existing.status,
        archived: (true if existing.deleted?),
      }.compact,
    }.compact
  end

  def self.no_match_hint(year)
    hint = "No matches. Try the original title or another spelling"
    hint += ", or drop the year" if year
    "#{hint}. If the catalog doesn't have it, use add_item with custom: true."
  end

  private_class_method :summarize_result, :no_match_hint
end
