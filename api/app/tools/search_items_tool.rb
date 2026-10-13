# frozen_string_literal: true

class SearchItemsTool < McpTool
  SORTS = {
    "added" => { created_at: :desc },
    "done" => Arel.sql("first_done_at DESC NULLS LAST"),
    "rating" => Arel.sql("rating DESC NULLS LAST"),
    "released" => Arel.sql("date DESC NULLS LAST"),
    "name" => { name: :asc },
    "random" => Arel.sql("RANDOM()"),
  }.freeze

  tool_name "search_items"
  description "Searches and filters items across the user's lists. Use it for " \
              "recommendations (e.g. the watchlist is status todo, taste shows " \
              "in highly rated done items), lookups and browsing. Returns compact " \
              "summaries with notes truncated; use get_item for full details."
  input_schema(
    properties: FILTER_PROPERTIES.merge(
      sort: {
        type: "string",
        enum: SORTS.keys,
        description: "Defaults to added (most recently added first).",
      },
      **PAGINATION_PROPERTIES,
    ),
  )
  annotations(**READ_ONLY)

  def self.run(user, sort: nil, limit: nil, offset: nil, **filters)
    order = SORTS.fetch(sort.presence || "added") do
      raise InvalidArgument, "sort must be one of #{SORTS.keys.join(", ")}"
    end

    items = filter_items(user, **filters).order(order).order(:id)
    paginate(items, limit:, offset:)
  end
end
