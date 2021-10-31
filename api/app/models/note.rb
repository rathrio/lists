# == Schema Information
#
# Table name: notes
#
#  id         :integer          not null, primary key
#  text       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  item_id    :integer
#
# Indexes
#
#  index_notes_on_item_id  (item_id)
#
# Foreign Keys
#
#  fk_rails_...  (item_id => items.id)
#
class Note < ApplicationRecord
  belongs_to :item
end
