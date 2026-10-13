# frozen_string_literal: true

class StatsTool < McpTool
  MAX_GROUPS = 100

  # Group expression and whether groups are chronological (sorted by key
  # instead of by count).
  GROUPINGS = {
    "list" => ["lists.name", false],
    "status" => ["items.status", false],
    "done_year" => ["EXTRACT(YEAR FROM items.first_done_at)::int", true],
    "done_month" => ["TO_CHAR(items.first_done_at, 'YYYY-MM')", true],
    "release_decade" => ["(EXTRACT(YEAR FROM items.date)::int / 10 * 10)", true],
    "rating" => ["items.rating", true],
    "tag" => ["tags.name", false],
    "language" => ["items.language", false],
    "recommended_by" => ["items.recommended_by", false],
  }.freeze

  tool_name "stats"
  description "Counts and average ratings of items grouped by list, status, " \
              "year or month finished, release decade, rating, tag, language or " \
              "recommender. Accepts the same filters as search_items. Cheaper " \
              "than paging through items for questions like \"how many movies " \
              "did I watch per year?\" or \"which tags do I rate highest?\"."
  input_schema(
    properties: FILTER_PROPERTIES.merge(
      group_by: { type: "string", enum: GROUPINGS.keys },
    ),
    required: ["group_by"],
  )
  annotations(**READ_ONLY)

  def self.run(user, group_by:, **filters)
    expression, chronological = GROUPINGS.fetch(group_by) do
      raise InvalidArgument, "group_by must be one of #{GROUPINGS.keys.join(", ")}"
    end

    items = filter_items(user, **filters)
    grouped = items
    grouped = grouped.joins(:list) if group_by == "list"
    grouped = grouped.joins(:tags) if group_by == "tag"
    grouped = grouped.where("#{expression} IS NOT NULL").group(Arel.sql(expression))

    counts = grouped.count
    averages = grouped.average(:rating)

    groups = counts.map do |key, count|
      average = averages[key]
      {
        key: group_by == "status" ? Item.statuses.key(key) || key : key,
        count:,
        avg_rating: average&.to_f&.round(2),
      }.compact
    end
    groups.sort_by! { |group| chronological ? group[:key] : -group[:count] }
    groups.reverse! if chronological

    {
      group_by:,
      total: items.count,
      truncated: (true if groups.size > MAX_GROUPS),
      groups: groups.first(MAX_GROUPS),
    }.compact
  end
end
