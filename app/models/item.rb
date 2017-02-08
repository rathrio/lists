class Item < ApplicationRecord
  has_many :links, dependent: :delete_all
  has_many :notes, dependent: :delete_all

  has_and_belongs_to_many :labels

  mount_uploader :image, ImageUploader

  validates :name, presence: true

  def self.with_labels(label_ids)
    joins(:items_labels).where('items_labels.label_id in (?)', label_ids)
  end

  def self.create_from(scraper_result)
    create!(scraper_result.merge(scraped: true))
  end

  def update_from(scraper_result)
    update_attributes!(scraper_result.merge(scraped: true))
  end

  def to_s
    name
  end

  def release_year
    release_date&.year
  end
end
