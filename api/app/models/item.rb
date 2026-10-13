# frozen_string_literal: true

class Item < ApplicationRecord
  acts_as_paranoid

  enum :status, %i[todo doing done]

  belongs_to :user
  belongs_to :list

  has_many :links

  has_and_belongs_to_many :tags

  mount_uploader :image, ImageUploader
  mount_uploader :backdrop_image, BackdropImageUploader

  validates :list, presence: true, unless: ->(item) { item.list_id.present? }
  validates :name, presence: true
  validates :rating, inclusion: 0..5, allow_blank: true

  # The journal date: when the item was finished for the first time.
  before_save :set_first_done_at, if: -> { will_save_change_to_status? && done? }

  # @param list_ids [Array<Integer>]
  def self.in_lists(list_ids)
    where(list_id: list_ids)
  end

  def self.with_tags(tag_ids)
    joins(:items_tags).where(items_tags: { tag_id: tag_ids }).distinct
  end

  def self.scraped
    where(scraped: true)
  end

  def self.unscraped
    where(scraped: false)
  end

  # Because paranaoia basically makes the default dependent hooks useless.
  # They'll actually delete the associated models even when soft deleting a
  # model.
  def really_destroy!
    links.delete_all
    super
  end

  # What's the int representation of the next status the item can toggle to?
  def next_status_index
    statuses = self.class.statuses
    (statuses.fetch(status) + 1) % statuses.length
  end

  def list_name
    list&.name
  end

  def fa_icon
    list&.fa_icon
  end

  def update_from(scraper_result, fields: [])
    attr = scraper_result.merge(scraped: true)
    attr.slice!(*fields) if fields.present?

    update!(attr)
  end

  # @param names [Array<String>], e.g. ["Horror", "Comedy"]
  def tags=(names)
    Item.transaction(requires_new: true) do
      tags.clear

      names.each do |name|
        tag = user.tags.find_or_create_by!(name:)
        tags << tag
      end
    end
  end

  def to_s
    name
  end

  def year
    date&.year
  end

  def human_status
    default_scraper&.human_status(status)
  end

  # @return [Class]
  def default_scraper
    list&.default_scraper
  end

  def scrape
    return if default_scraper.nil?

    default_scraper
      .new(
        query: name,
        filter_values: [{ "filter" => "year", "value" => year }],
      )
      .scrape
      .first
  end

  # @param fields [Array<Symbol>]
  def scrape_and_update(fields:)
    scraper_result = scrape
    if scraper_result.nil?
      Rails.logger.warn(
        "Cannot update item #{self} because scraper result is nil"
      )
      return
    end

    update_from(scraper_result, fields:)
  end

  # TMDB id from scraped metadata — the join key towards Jellyseerr and
  # Jellyfin. Unscraped items don't have one and can't be matched.
  def tmdb_id
    metadata&.dig("tmdb_id")
  end

  # @return [Symbol] :movie or :tv
  def media_type
    list.tv? ? :tv : :movie
  end

  def requestable?
    (list.movies? || list.tv?) && tmdb_id.present?
  end

  # Jellyseerr availability, looked up live over the tailnet and briefly
  # cached. Only call this on requestable items.
  #
  # @return [Hash] { status:, watch_url:, seasons:, available_since: } where
  #   status is Jellyseerr's media status — nil = never requested ·
  #   2 pending · 3 processing · 4 partially available · 5 available.
  def availability
    Rails.cache.fetch(availability_cache_key, expires_in: 2.minutes) do
      availability_payload(JellyseerrClient.new.media_info(tmdb_id, type: media_type))
    end
  end

  # Requests the item on Jellyseerr. Only call this on requestable items.
  #
  # @return [Hash] see #availability
  def request_download!
    media = JellyseerrClient.new.request_media(tmdb_id, type: media_type)
    availability_payload(media).tap do |payload|
      Rails.cache.write(availability_cache_key, payload, expires_in: 2.minutes)
    end
  end

  def public_image_url
    url = image&.url
    Rails.env.production? ? "https://lists.rathr.io/api/#{url}" : "http://localhost:3000/#{url}"
  end

  def as_json(*)
    super.tap do |hash|
      hash["tags"] = tags.map(&:name)
      hash["list"] = list_name
      hash["fa_icon"] = fa_icon
      hash["year"] = year
      hash["language"] = language
      hash["deleted"] = deleted?
      hash["human_status"] = human_status
    end
  end

  private

  def set_first_done_at
    self.first_done_at ||= Date.today
  end

  def availability_cache_key
    "jellyseerr/availability/#{media_type}/#{tmdb_id}"
  end

  # @param media [Hash, nil] Jellyseerr's media hash — "mediaInfo" on GET,
  #   "media" on POST. nil means the title was never requested.
  def availability_payload(media)
    payload = { status: media&.fetch("status", nil) }
    return payload if media.nil?

    payload.merge(
      watch_url: watch_url(media["jellyfinMediaId"]),
      seasons: media["seasons"],
      available_since: media["mediaAddedAt"],
    ).compact
  end

  # Built by hand instead of using Jellyseerr's mediaUrl, which points at the
  # LAN address of Jellyfin and is dead from anywhere but home.
  def watch_url(jellyfin_media_id)
    return nil if jellyfin_media_id.blank?

    "#{ENV.fetch("JELLYFIN_WEB_URL")}/web/index.html#!/details" \
      "?id=#{jellyfin_media_id}&serverId=#{ENV.fetch("JELLYFIN_SERVER_ID")}"
  end
end
