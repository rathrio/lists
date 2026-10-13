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
    item = user.items.with_deleted.includes(:list, :tags, :links).find(id)

    summarize(item).merge(
      human_status: item.human_status,
      release_date: item.date,
      description: item.description.presence,
      notes: item.notes.presence,
      links: item.links.map { |link| { name: link.name, url: link.url } }.presence,
      tmdb_id: item.tmdb_id,
      tv: tv_metadata(item),
      archived_on: item.deleted_at&.to_date,
    ).compact
  end

  # Scraped TV metadata minus the bulky bits (posters, overviews).
  def self.tv_metadata(item)
    metadata = item.metadata || {}
    return nil if metadata["seasons"].blank?

    episode = ->(e) { e&.slice("name", "air_date", "season_number", "episode_number") }
    {
      seasons: metadata["seasons"].map do |s|
        s.slice("season_number", "name", "air_date", "episode_count")
      end,
      last_episode_to_air: episode.call(metadata["last_episode_to_air"]),
      next_episode_to_air: episode.call(metadata["next_episode_to_air"]),
    }.compact
  end
  private_class_method :tv_metadata
end
