# == Schema Information
#
# Table name: notifications
#
#  id         :integer          not null, primary key
#  subject    :string           not null
#  body       :string
#  key        :string           not null
#  user_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_notifications_on_key      (key) UNIQUE
#  index_notifications_on_user_id  (user_id)
#

require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
