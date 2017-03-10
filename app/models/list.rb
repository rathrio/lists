class List < ApplicationRecord
  has_and_belongs_to_many :items
  belongs_to :user

  validates :name, presence: true

  def self.create_defaults(user)
    user.lists.find_or_create_by(name: 'Movies', scraper: 'MovieScraper', fa_icon: 'film')
    user.lists.find_or_create_by(name: 'TV', scraper: 'TvScraper', fa_icon: 'television')
    user.lists.find_or_create_by(name: 'Music', scraper: 'AlbumScraper', fa_icon: 'music')
    user.lists.find_or_create_by(name: 'Games', scraper: 'GameScraper', fa_icon: 'gamepad')
    user.lists.find_or_create_by(name: 'Recipes', scraper: 'RecipeScraper', fa_icon: 'cutlery')
    user.lists.find_or_create_by(name: 'Books', scraper: 'BookScraper', fa_icon: 'book')
  end

  def default_scraper
    scraper.constantize if scraper.present?
  end

  def to_s
    name
  end
end
