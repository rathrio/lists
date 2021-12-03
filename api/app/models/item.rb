# frozen_string_literal: true

# == Schema Information
#
# Table name: items
#
#  id             :integer          not null, primary key
#  backdrop_image :string
#  date           :date
#  deleted_at     :datetime
#  description    :string
#  first_done_at  :date
#  image          :string
#  language       :string
#  metadata       :jsonb
#  name           :string
#  original_name  :string
#  quantity       :integer          default(0)
#  rating         :float
#  recommended_by :string
#  scraped        :boolean          default(FALSE)
#  status         :integer          default("todo")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  list_id        :integer
#  user_id        :integer
#
# Indexes
#
#  index_items_on_deleted_at      (deleted_at)
#  index_items_on_first_done_at   (first_done_at)
#  index_items_on_language        (language)
#  index_items_on_list_id         (list_id)
#  index_items_on_metadata        (metadata)
#  index_items_on_name            (name)
#  index_items_on_original_name   (original_name)
#  index_items_on_rating          (rating)
#  index_items_on_recommended_by  (recommended_by)
#  index_items_on_status          (status)
#  index_items_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Item < ApplicationRecord
  acts_as_paranoid

  enum status: %i[todo doing done]

  belongs_to :user
  belongs_to :list

  has_many :links
  has_many :notes

  has_and_belongs_to_many :tags

  mount_uploader :image, ImageUploader
  mount_uploader :backdrop_image, BackdropImageUploader

  validates :list, presence: true, unless: ->(item) { item.list_id.present? }
  validates :name, presence: true
  validates :rating, inclusion: 0..5, allow_blank: true

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
    notes.delete_all
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
        tag = user.tags.find_or_create_by!(name: name)
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
        filter_values: [{ 'filter' => 'year', 'value' => year }]
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

    update_from(scraper_result, fields: fields)
  end

  def as_json(*)
    super.tap do |hash|
      hash['tags'] = tags.map(&:name)
      hash['list'] = list_name
      hash['fa_icon'] = fa_icon
      hash['year'] = year
      hash['language'] = language
      hash['deleted'] = deleted?
      hash['human_status'] = human_status
      hash['notes'] = notes
    end
  end
end
