class Label < ApplicationRecord
  has_and_belongs_to_many :items
  belongs_to :user

  validates :name, presence: true

  def self.create_defaults(user)
    
  end

  def default_scraper
    scraper.constantize if scraper.present?
  end

  def to_s
    name
  end
end
