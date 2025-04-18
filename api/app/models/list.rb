class List < ApplicationRecord
  belongs_to :user
  has_many :items

  validates :name, presence: true

  # @param user [User] for whom the default lists will be created.
  def self.create_defaults(user)
    user.lists.find_or_create_by(name: "Movies", scraper: "MovieScraper", fa_icon: "film", cover_aspect_ratio: "2by3")
    user.lists.find_or_create_by(name: "TV", scraper: "TvScraper", fa_icon: "tv", cover_aspect_ratio: "2by3")
    user.lists.find_or_create_by(name: "Music", scraper: "AlbumScraper", fa_icon: "music", cover_aspect_ratio: "1by1")
    user.lists.find_or_create_by(name: "Games", scraper: "GameScraper", fa_icon: "gamepad", cover_aspect_ratio: "3by4")
    user.lists.find_or_create_by(name: "Books", scraper: "BookScraper", fa_icon: "book", cover_aspect_ratio: "2by3")
  end

  def default_scraper
    scraper.constantize if scraper.present?
  end

  def to_s
    name
  end
end
