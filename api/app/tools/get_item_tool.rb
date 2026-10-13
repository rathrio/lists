# frozen_string_literal: true

class GetItemTool < McpTool
  tool_name "get_item"
  description "Full details of a single item, including its description, " \
              "complete notes, links and TV season info."
  input_schema(
    properties: { id: { type: "integer" } },
    required: ["id"],
  )
  annotations(**READ_ONLY)

  def self.run(user, id:)
    details(user.items.with_deleted.includes(:list, :tags, :links).find(id))
  end
end
