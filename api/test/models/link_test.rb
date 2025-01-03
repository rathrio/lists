# == Schema Information
#
# Table name: links
#
#  id         :integer          not null, primary key
#  name       :string
#  url        :string
#  item_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_links_on_item_id  (item_id)
#

require 'test_helper'

class LinkTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
