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
# Indexes
#
#  index_tags_on_name     (name)
#  index_tags_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Tag < ActiveRecord::Base
  has_and_belongs_to_many :items
  belongs_to :user

  validates :name, presence: true, uniqueness: { scope: :user_id }

  def to_s
    name
  end
end
