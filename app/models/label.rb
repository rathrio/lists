class Label < ApplicationRecord
  has_and_belongs_to_many :items

  validates :name, uniqueness: true, presence: true

  def default_scraper
    scraper&.constantize
  end

  def to_s
    name
  end
end
