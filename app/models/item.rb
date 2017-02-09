class Item < ApplicationRecord
  acts_as_paranoid

  has_many :links, dependent: :delete_all
  has_many :notes, dependent: :delete_all

  has_and_belongs_to_many :labels

  mount_uploader :image, ImageUploader

  validates :name, presence: true

  def self.with_labels(label_ids)
    joins(:items_labels).where('items_labels.label_id in (?)', label_ids)
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

  def to_s
    name
  end

  def year
    date&.year
  end

  def lucky_scrape
    scraper = labels.first&.default_scraper

    if scraper.nil?
      return false
    else
      result = scraper.new(query: name).scrape.first
      update_from(result) if result
    end
  end
end
