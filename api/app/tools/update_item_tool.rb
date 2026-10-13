# frozen_string_literal: true

class UpdateItemTool < McpTool
  tool_name "update_item"
  description "Changes an item: status (e.g. mark as watched/read), rating, notes, " \
              "who recommended it, tags, or details of items not found in the " \
              "catalog. Only the given fields change; null clears a field. Returns " \
              "the updated item."
  input_schema(
    properties: {
      id: { type: "integer" },
      **ITEM_PROPERTIES,
      notes: {
        **ITEM_PROPERTIES[:notes],
        description: "#{ITEM_PROPERTIES[:notes][:description]} Replaces all existing " \
                     "notes — prefer append_note to add to them.",
      },
      append_note: {
        type: "string",
        description: "Adds a paragraph to the end of the existing notes.",
      },
      tags: {
        **ITEM_PROPERTIES[:tags],
        description: "#{ITEM_PROPERTIES[:tags][:description]} Replaces all existing tags.",
      },
    },
    required: ["id"],
  )
  annotations(
    read_only_hint: false,
    destructive_hint: true,
    idempotent_hint: false,
    open_world_hint: false,
  )

  def self.run(user, id:, append_note: nil, **fields)
    item = user.items.with_deleted.includes(:list, :tags, :links).find(id)
    attributes = item_attributes(fields)
    attributes[:tags] = normalize_tags(user, attributes[:tags] || []) if attributes.key?(:tags)

    if append_note.present?
      notes = attributes.fetch(:notes) { item.notes }
      attributes[:notes] = [notes.presence&.rstrip, append_note.strip].compact.join("\n\n")
    end

    item.update!(attributes)
    details(item)
  end
end
