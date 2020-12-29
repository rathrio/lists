# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime
#  updated_at :datetime
#  user_id    :integer
#
class Tag < ActiveRecord::Base
  has_and_belongs_to_many :items
  belongs_to :user

  validates :name, presence: true, uniqueness: { scope: :user_id }

  def to_s
    name
  end
end
