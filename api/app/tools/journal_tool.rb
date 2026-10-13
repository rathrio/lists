# frozen_string_literal: true

class JournalTool < McpTool
  tool_name "journal"
  description "The user's media journal: finished items ordered by the date " \
              "they were first finished, most recent first. Use it for questions " \
              "like \"what did I watch in March?\" or \"which books did I read " \
              "last year?\". Rewatches/rereads are not tracked."
  input_schema(
    properties: {
      from: { type: "string", format: "date",
              description: "First finished on or after (YYYY-MM-DD)." },
      to: { type: "string", format: "date",
            description: "First finished on or before (YYYY-MM-DD)." },
      list: FILTER_PROPERTIES[:list],
      **PAGINATION_PROPERTIES,
    },
  )
  annotations(**READ_ONLY)

  def self.run(user, from: nil, to: nil, list: nil, limit: nil, offset: nil)
    items = filter_items(user, status: "done", list:, done_from: from, done_to: to)
            .where.not(first_done_at: nil)
            .order(first_done_at: :desc, id: :desc)

    paginate(items, limit:, offset:)
  end
end
