class Item < ApplicationRecord
  acts_as_paranoid

  has_many :links, dependent: :delete_all
  has_many :notes, dependent: :delete_all

  has_and_belongs_to_many :labels
  has_and_belongs_to_many :tags

  mount_uploader :image, ImageUploader

  validates :name, presence: true

  def self.with_labels(label_ids)
    joins(:items_labels).where('items_labels.label_id IN (?)', label_ids)
  end

  def self.with_tags(tag_ids)
    joins(:items_tags).where('items_tags.tag_id IN (?)', tag_ids)
  end

  def self.scraped
    where(scraped: true)
  end

  def self.unscraped
    where(scraped: false)
  end

  def self.create_from(scraper_result)
    create!(scraper_result.merge(scraped: true))
  end

  def self.lucky_scrape(label_ids)
    with_labels(label_ids).unscraped.includes(:labels).each(&:lucky_scrape)
  end

  def update_from(scraper_result)
    update_attributes!(scraper_result.merge(scraped: true))
  end

  def tags=(names)
    names.each do |name|
      tag = Tag.find_or_create_by(name: name)
      self.tags << tag unless tags.include?(tag)
    end
  end

  def to_s
    name
  end

  def year
    date&.year
  end

  def default_scraper
    labels.map(&:default_scraper).compact.first
  end

  def lucky_scrape
    scraper = labels.first&.default_scraper

    if scraper.nil?
      return false
    else
      results = scraper.new(query: name).scrape
      result = results.find { |r| r[:remote_image_url].present? }
      result = results.first if result.nil?

      update_from(result) if result
    end
  end
end
