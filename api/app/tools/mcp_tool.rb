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

  # JSON schema properties of the item attributes add_item and update_item
  # can set, see .item_attributes. Nullable ones can be cleared on update.
  ITEM_PROPERTIES = {
    status: {
      type: "string",
      enum: Item.statuses.keys,
      description: "todo = backlog/watchlist, doing = in progress, done = finished. " \
                   "Becoming done sets done_on to today unless it's already set.",
    },
    rating: {
      type: %w[number null],
      minimum: 0,
      maximum: 5,
      description: "The user's rating from 0 to 5. Only set what the user said.",
    },
    notes: {
      type: %w[string null],
      description: "Personal notes, written in the user's voice.",
    },
    recommended_by: {
      type: %w[string null],
      description: "Who or what recommended the item, e.g. a friend's name or \"Reddit\".",
    },
    tags: {
      type: "array",
      items: { type: "string" },
      description: "Tags, mostly genres. Reuse existing tag names where they fit.",
    },
    done_on: {
      type: %w[string null],
      format: "date",
      description: "When the user first finished the item (YYYY-MM-DD), i.e. its " \
                   "journal date. Only needed when it wasn't today.",
    },
    name: {
      type: "string",
      description: "Display name, usually the English title. Music is \"Artist - Album\".",
    },
    original_name: {
      type: %w[string null],
      description: "Title in the original language, if it differs from name.",
    },
    description: {
      type: %w[string null],
      description: "Short synopsis.",
    },
    release_date: {
      type: %w[string null],
      format: "date",
      description: "YYYY-MM-DD. Use year instead when only the year is known.",
    },
    year: {
      type: "integer",
      description: "Release year, if the exact release_date is unknown.",
    },
    image_url: {
      type: "string",
      format: "uri",
      description: "URL of a cover image (poster, book cover, album art) to download.",
    },
    language: {
      type: %w[string null],
      description: "ISO 639-1 original language code, e.g. \"ja\".",
    },
  }.freeze

  # External ids in scraped metadata identifying the same title for sure.
  EXTERNAL_IDS = %w[tmdb_id mbid].freeze

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
    rescue ActiveRecord::RecordInvalid => e
      error(e.record.errors.full_messages.to_sentence)
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

    # Everything about an item, as returned by get_item.
    def details(item)
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
    def tv_metadata(item)
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

    # Translates ITEM_PROPERTIES arguments into Item attributes. Only given
    # keys are touched; nil clears.
    #
    # @return [Hash]
    def item_attributes(fields)
      fields = fields.slice(*ITEM_PROPERTIES.keys)
      year = fields.delete(:year)
      fields[:release_date] = "#{year}-01-01" if year && !fields.key?(:release_date)

      fields.to_h do |key, value|
        case key
        when :release_date then [:date, value && parse_date(value)]
        when :done_on then [:first_done_at, value && parse_date(value)]
        when :image_url then [:remote_image_url, value]
        else [key, value]
        end
      end
    end

    # Reuses the spelling of the user's existing tags ("horror" => "Horror"),
    # since Item#tags= creates tags by exact name.
    #
    # @return [Array<String>]
    def normalize_tags(user, names)
      known = user.tags.pluck(:name).index_by(&:downcase)
      names.map { |name| known.fetch(name.strip.downcase, name.strip) }.uniq(&:downcase)
    end

    # The item of list that most likely is the same title, archived ones
    # included. Matches on external ids of scraped metadata, falling back to
    # the name (or original name) and release year.
    #
    # @return [Item, nil]
    def find_existing(list, name:, date: nil, metadata: nil)
      items = list.items.with_deleted
      metadata = (metadata || {}).stringify_keys

      EXTERNAL_IDS.each do |key|
        next if metadata[key].blank?

        match = items.find_by("items.metadata ->> ? = ?", key, metadata[key].to_s)
        return match if match
      end

      matches = items.where(
        "LOWER(items.name) = LOWER(:name) OR LOWER(items.original_name) = LOWER(:name)",
        name:,
      )
      matches = matches.where(date: nil).or(matches.where(date: date.all_year)) if date
      matches.first
    end

    def describe_existing(item)
      "#{item.list_name} item #{item.id} (#{item.name}, #{item.year || "no year"}, " \
        "status #{item.status}#{", archived" if item.deleted?})"
    end
  end
end
