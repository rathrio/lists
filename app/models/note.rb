# == Schema Information
#
# Table name: notes
#
#  id         :integer          not null, primary key
#  text       :text
#  item_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Note < ApplicationRecord
  belongs_to :item
end
