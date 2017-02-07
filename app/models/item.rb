class Item < ApplicationRecord
  has_many :links
  has_many :notes

  mount_uploader :image, ImageUploader

  validates :name, presence: true

  def self.create_from(scraper_result)
    create!(scraper_result.merge(scraped: true))
  end

  def update_from(scraper_result)
    update_attributes!(scraper_result.merge(scraped: true))
  end
end
