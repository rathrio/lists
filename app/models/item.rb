class Item < ApplicationRecord
  acts_as_paranoid

  enum status: %i(todo doing done)

  belongs_to :user
  belongs_to :list

  has_many :links, dependent: :delete_all
  has_many :notes, dependent: :delete_all

  has_and_belongs_to_many :tags

  mount_uploader :image, ImageUploader

  validates :list, presence: true
  validates :name, presence: true, uniqueness: { scope: %i[user_id date] }

  after_create :scrape_in_background, unless: -> { Rails.env.test? || scraped? }

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

  def list_name
    list&.name
  end

  def update_from(scraper_result)
    update_attributes!(scraper_result.merge(scraped: true))
  end

  def tags=(names)
    names.each do |name|
      tag = user.tags.find_or_create_by(name: name)
      self.tags << tag unless tags.include?(tag)
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

  def default_scraper
    list&.default_scraper
  end

  def lucky_scrape
    scraper = default_scraper
    return false if scraper.nil?

    results = scraper.new(query: name).scrape
    result = results.find { |r| r[:remote_image_url].present? }
    result = results.first if result.nil?

    update_from(result) if result
  end

  def as_json(*)
    super.tap do |hash|
      hash['tags'] = tags.map(&:name)
      hash['list'] = list_name
      hash['year'] = year
      hash['deleted'] = deleted?
      hash['human_status'] = human_status
    end
  end

  private

  def scrape_in_background
    ScrapeJob.perform_later(id)
  end
end
