class Tag < ActiveRecord::Base
  has_and_belongs_to_many :items
  belongs_to :user

  validates :name, presence: true, uniqueness: { scope: :user_id }

  def to_s
    name
  end
end
