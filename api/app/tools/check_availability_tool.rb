# frozen_string_literal: true

class CheckAvailabilityTool < McpTool
  MAX_ITEMS = 25

  STATUS_NAMES = {
    nil => "not_requested",
    1 => "unknown",
    2 => "pending",
    3 => "processing",
    4 => "partially_available",
    5 => "available",
  }.freeze

  tool_name "check_availability"
  description "Checks whether movies or TV shows are available to watch on the " \
              "user's Jellyfin media server (via Jellyseerr). Use it to narrow " \
              "recommendations down to what can be watched right away. Only " \
              "scraped movie and TV items can be checked."
  input_schema(
    properties: {
      item_ids: {
        type: "array",
        items: { type: "integer" },
        minItems: 1,
        maxItems: MAX_ITEMS,
      },
    },
    required: ["item_ids"],
  )
  annotations(**READ_ONLY.merge(open_world_hint: true))

  def self.run(user, item_ids:)
    items = user.items.with_deleted.includes(:list).where(id: item_ids.first(MAX_ITEMS))

    items.sort_by { |item| item_ids.index(item.id) }.map do |item|
      { id: item.id, name: item.name }.merge(availability(item))
    end
  end

  def self.availability(item)
    return { status: "not_checkable" } unless item.requestable?

    availability = item.availability
    {
      status: STATUS_NAMES.fetch(availability[:status], availability[:status].to_s),
      watch_url: availability[:watch_url],
      available_since: availability[:available_since],
      seasons: availability[:seasons]&.map do |season|
        { season: season["seasonNumber"], status: STATUS_NAMES[season["status"]] }
      end,
    }.compact
  rescue StandardError => e
    Rails.logger.warn("[MCP] Jellyseerr availability for item #{item.id} failed: #{e.message}")
    { status: "lookup_failed" }
  end
  private_class_method :availability
end
