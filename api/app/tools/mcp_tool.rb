# frozen_string_literal: true

# Shared plumbing for the MCP tools: user scoping, item filters, compact
# item serialization and error handling.
#
# Subclasses implement `.run(user, **arguments)` and return a JSON-able
# object. Raising InvalidArgument turns into a tool error Claude can read and
# correct, as opposed to the SDK's opaque "Internal error".
class McpTool < MCP::Tool
  class InvalidArgument < StandardError; end

  DEFAULT_LIMIT = 50
  MAX_LIMIT = 200
  NOTES_PREVIEW_LENGTH = 200

  READ_ONLY = {
    read_only_hint: true,
    destructive_hint: false,
    idempotent_hint: true,
    open_world_hint: false,
  }.freeze

  # JSON schema properties of the filters understood by .filter_items.
  FILTER_PROPERTIES = {
    list: {
      type: "string",
      description: "List name (e.g. \"Movies\", case-insensitive) or id. See list_lists.",
    },
    status: {
      type: "string",
      enum: Item.statuses.keys,
      description: "todo = backlog/watchlist, doing = in progress, done = finished.",
    },
    query: {
      type: "string",
      description: "Case-insensitive substring match on name, original name, " \
                   "description and notes.",
    },
    tags: {
      type: "array",
      items: { type: "string" },
      description: "Match items having any of these tags (case-insensitive).",
    },
    min_rating: {
      type: "number",
      minimum: 0,
      maximum: 5,
      description: "Only items rated at least this (ratings go from 0 to 5).",
    },
    recommended_by: {
      type: "string",
      description: "Case-insensitive substring match on who recommended the item.",
    },
    language: {
      type: "string",
      description: "ISO 639-1 original language code, e.g. \"ja\".",
    },
    released_from: {
      type: "integer",
      description: "Only items released in or after this year.",
    },
    released_to: {
      type: "integer",
      description: "Only items released in or before this year.",
    },
    done_from: {
      type: "string",
      format: "date",
      description: "Only items first finished on or after this date (YYYY-MM-DD).",
    },
    done_to: {
      type: "string",
      format: "date",
      description: "Only items first finished on or before this date (YYYY-MM-DD).",
    },
    archived: {
      type: "string",
      enum: %w[exclude include only],
      description: "Archived items were removed from their list, often because " \
                   "they were dropped or lost interest. Defaults to exclude.",
    },
  }.freeze

  PAGINATION_PROPERTIES = {
    limit: {
      type: "integer",
      minimum: 1,
      maximum: MAX_LIMIT,
      description: "Defaults to #{DEFAULT_LIMIT}.",
    },
    offset: { type: "integer", minimum: 0 },
  }.freeze

  class << self
    def call(server_context:, **arguments)
      respond(run(server_context[:user], **arguments))
    rescue InvalidArgument => e
      error(e.message)
    rescue ActiveRecord::RecordNotFound => e
      error("#{e.model} #{e.id} not found")
    end

    private

    def respond(data)
      MCP::Tool::Response.new([{ type: "text", text: JSON.generate(data) }])
    end

    def error(message)
      MCP::Tool::Response.new([{ type: "text", text: message }], error: true)
    end

    # @param user [User]
    # @return [ActiveRecord::Relation<Item>]
    def filter_items(user, list: nil, status: nil, query: nil, tags: nil,
      min_rating: nil, recommended_by: nil, language: nil,
      released_from: nil, released_to: nil, done_from: nil,
      done_to: nil, archived: nil)
      items = archived_scope(user.items, archived)

      items = items.where(list: find_list(user, list)) if list.present?
      items = items.where(status:) if status.present?
      items = items.where(rating: min_rating..) if min_rating
      items = items.where("items.language ILIKE ?", language) if language.present?
      items = items.where(date: Date.new(released_from)..) if released_from
      items = items.where(date: ..Date.new(released_to, 12, 31)) if released_to
      items = items.where(first_done_at: parse_date(done_from)..) if done_from.present?
      items = items.where(first_done_at: ..parse_date(done_to)) if done_to.present?

      if recommended_by.present?
        items = items.where("items.recommended_by ILIKE ?",
                            "%#{Item.sanitize_sql_like(recommended_by)}%")
      end

      if query.present?
        pattern = "%#{Item.sanitize_sql_like(query)}%"
        items = items.where(
          "items.name ILIKE :pattern OR items.original_name ILIKE :pattern " \
          "OR items.description ILIKE :pattern OR items.notes ILIKE :pattern",
          pattern:,
        )
      end

      if tags.present?
        tagged = Item.with_deleted.joins(:tags)
                     .where("LOWER(tags.name) IN (?)", tags.map(&:downcase))
                     .select(:id)
        items = items.where(id: tagged)
      end

      items
    end

    def archived_scope(items, archived)
      case archived.presence || "exclude"
      when "exclude" then items
      when "include" then items.with_deleted
      when "only" then items.only_deleted
      else raise InvalidArgument, "archived must be one of exclude, include, only"
      end
    end

    def find_list(user, name_or_id)
      list = user.lists.find_by("LOWER(name) = ?", name_or_id.to_s.downcase)
      list ||= user.lists.find_by(id: name_or_id) if name_or_id.to_s.match?(/\A\d+\z/)
      return list if list

      known = user.lists.order(:name).pluck(:name).join(", ")
      raise InvalidArgument, "Unknown list #{name_or_id.inspect}. Known lists: #{known}"
    end

    def parse_date(value)
      Date.iso8601(value)
    rescue Date::Error
      raise InvalidArgument, "#{value.inspect} is not a date like 2025-01-31"
    end

    # @return [Hash] a page of compact item summaries
    def paginate(items, limit:, offset:)
      limit = (limit || DEFAULT_LIMIT).clamp(1, MAX_LIMIT)
      offset = [offset.to_i, 0].max
      total = items.count
      page = items.includes(:list, :tags).limit(limit).offset(offset).to_a

      {
        total:,
        offset:,
        next_offset: (offset + page.size if offset + page.size < total),
        items: page.map { |item| summarize(item) },
      }.compact
    end

    # Compact representation for listings — get_item has the full details.
    def summarize(item)
      {
        id: item.id,
        name: item.name,
        original_name: (item.original_name unless item.original_name == item.name).presence,
        list: item.list_name,
        year: item.year,
        status: item.status,
        rating: item.rating,
        tags: item.tags.map(&:name).presence,
        recommended_by: item.recommended_by.presence,
        language: item.language.presence,
        done_on: item.first_done_at,
        added_on: item.created_at.to_date,
        archived: (true if item.deleted?),
        notes: item.notes&.truncate(NOTES_PREVIEW_LENGTH).presence,
      }.compact
    end
  end
end
