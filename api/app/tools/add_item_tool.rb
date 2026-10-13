# frozen_string_literal: true

class AddItemTool < McpTool
  tool_name "add_item"
  description "Adds an item to a list. By default it's looked up in the list's " \
              "catalog by name and year (as shown by search_catalog), which fills in " \
              "cover, genres, release date, TMDB id and more. Only if the catalog " \
              "doesn't have the title, pass custom: true plus whatever details you " \
              "can find (image_url, year, description, ...). Refuses titles already " \
              "in the list, archived ones included — use update_item for those. New " \
              "items default to status todo, i.e. the backlog/watchlist."
  input_schema(
    properties: {
      list: FILTER_PROPERTIES[:list],
      **ITEM_PROPERTIES,
      name: {
        **ITEM_PROPERTIES[:name],
        description: "Exactly as search_catalog returned it, unless custom.",
      },
      year: {
        **ITEM_PROPERTIES[:year],
        description: "Release year as search_catalog returned it. Tells remakes " \
                     "and namesakes apart.",
      },
      custom: {
        type: "boolean",
        description: "Skip the catalog and add the item with the given details " \
                     "only. Implied for lists without a catalog.",
      },
      tags: {
        **ITEM_PROPERTIES[:tags],
        description: "#{ITEM_PROPERTIES[:tags][:description]} Added to the genres " \
                     "from the catalog.",
      },
    },
    required: %w[list name],
  )
  annotations(
    read_only_hint: false,
    destructive_hint: false,
    idempotent_hint: false,
    open_world_hint: true,
  )

  def self.run(user, list:, name:, custom: false, tags: nil, **fields)
    list = find_list(user, list)
    attributes = {}

    if !custom && list.default_scraper
      result = find_catalog_result(list, name:, year: fields[:year])
      attributes = result.merge(scraped: true)
      fields = fields.except(:year) # Already in the catalog result.
    else
      fields[:name] = name
    end

    attributes.merge!(item_attributes(fields))
    attributes[:tags] = normalize_tags(user, Array(attributes[:tags]) + Array(tags))

    existing = find_existing(list, name: attributes[:name], date: attributes[:date],
                                   metadata: attributes[:metadata])
    if existing
      raise InvalidArgument, "Already added as #{describe_existing(existing)}. " \
                             "Use update_item to change it."
    end

    item = user.items.new(list:)
    item.update!(attributes)
    details(item)
  end

  # Runs the search_catalog search again and picks the result named name.
  # Several matches are usually editions of the same title, so the first,
  # best ranked one wins.
  #
  # @return [Hash] see Scraper#scrape
  def self.find_catalog_result(list, name:, year:)
    results = SearchCatalogTool.search(list, query: name, year:)
    match = results.find do |result|
      [result[:name], result[:original_name]].compact.any? { |n| n.casecmp?(name) } &&
        (year.nil? || result[:date]&.year == year)
    end
    return match if match

    found = results.map { |result| "#{result[:name]} (#{result[:date]&.year || "no year"})" }
    raise InvalidArgument,
          "#{name.inspect}#{" (#{year})" if year} isn't in the catalog. " \
          "#{found.any? ? "Found: #{found.join(", ")}." : "Nothing found."} " \
          "Use a name exactly as search_catalog returns it, or custom: true."
  end
  private_class_method :find_catalog_result
end
