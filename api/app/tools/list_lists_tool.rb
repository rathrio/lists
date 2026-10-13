# frozen_string_literal: true

class ListListsTool < McpTool
  tool_name "list_lists"
  description "Lists the user's media lists (e.g. Movies, TV, Books, Games, Music) " \
              "with item counts per status. A good first call to get oriented."
  annotations(**READ_ONLY)

  def self.run(user)
    counts = user.items.group(:list_id, :status).count
    archived = user.items.only_deleted.group(:list_id).count

    user.lists.order(:id).map do |list|
      {
        id: list.id,
        name: list.name,
        description: list.description.presence,
        counts: Item.statuses.keys.index_with { |status| counts.fetch([list.id, status], 0) },
        archived: archived.fetch(list.id, 0),
      }.compact
    end
  end
end
