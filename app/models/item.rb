class Item < ApplicationRecord
  has_many :links
  has_many :notes

  mount_uploader :image, ImageUploader

  def self.create_from(scraper_result)
    create!(scraper_result)
  end
end
