# frozen_string_literal: true

# == Schema Information
#
# Table name: items
#
#  id             :integer          not null, primary key
#  backdrop_image :string
#  date           :date
#  deleted_at     :datetime
#  description    :string
#  first_done_at  :date
#  image          :string
#  language       :string
#  metadata       :jsonb
#  name           :string
#  original_name  :string
#  quantity       :integer          default(0)
#  rating         :float
#  recommended_by :string
#  scraped        :boolean          default(FALSE)
#  status         :integer          default("todo")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  list_id        :integer
#  user_id        :integer
#
# Indexes
#
#  index_items_on_deleted_at      (deleted_at)
#  index_items_on_first_done_at   (first_done_at)
#  index_items_on_language        (language)
#  index_items_on_list_id         (list_id)
#  index_items_on_metadata        (metadata)
#  index_items_on_name            (name)
#  index_items_on_original_name   (original_name)
#  index_items_on_rating          (rating)
#  index_items_on_recommended_by  (recommended_by)
#  index_items_on_status          (status)
#  index_items_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class ItemTest < ActiveSupport::TestCase
  test "Name has not to be unique when assigned to different users" do
    list = create(:list, name: "Music")
    item1 = create(:item, name: "pigeon", list: list)
    item2 = create(:item, name: "pigeon", list: list)
    assert item1.valid?
    assert item2.valid?
  end

  test "Items require a non-empty name" do
    user = create(:user)
    list = create(:list, name: "Music")
    item1 = build(:item, name: "", list: list, user: user)
    item2 = build(:item, name: "singstar adventures", list: list, user: user)
    assert_not item1.valid?
    assert item2.valid?
  end

  test ".in_lists(list_ids) returns items that are associated with one of list_ids" do
    list1 = create(:list, name: "Music")
    list2 = create(:list, name: "TV")

    i1 = create(:item, name: "item1", list: list1)
    i2 = create(:item, name: "item3", list: list2)
    i3 = create(:item, name: "item3", list: list1)

    assert_equal [i1, i3], Item.in_lists([list1.id]).order(:id)
    assert_equal [i1, i2, i3], Item.in_lists([list1.id, list2.id]).order(:id)
    assert_equal [i2], Item.in_lists([list2.id]).order(:id)

    assert_empty Item.in_lists([43123])
  end

  test ".with_tags(tag_ids) returns items that are associated with one of tag_ids" do
    user = create(:user)

    tag1 = create(:tag, name: "Low Fi", user: user)
    tag2 = create(:tag, name: "Space Rock", user: user)

    i1 = create(:item, name: "item1", tags: ["Low Fi"], user: user)
    i2 = create(:item, name: "item2", tags: ["Low Fi", "Space Rock"], user: user)
    i3 = create(:item, name: "item3", tags: ["Space Rock"], user: user)

    assert_equal [i1, i2], user.items.with_tags([tag1.id]).order(:id)
    assert_equal [i1, i2, i3], user.items.with_tags([tag1.id, tag2.id]).order(:id)
    assert_equal [i2, i3], user.items.with_tags([tag2.id]).order(:id)

    assert_empty user.items.with_tags([43123])
  end

  test "#update_from(scraper_result) sets scraped to true" do
    item = create(:item, name: "Hello")
    refute item.scraped

    result = { name: "Foobar" }
    item.update_from(result)
    assert item.scraped
    assert_equal "Foobar", item.name
  end

  test "links are only destroyed on a real destroy" do
    item = create(:item)
    link = item.links.create!

    item.destroy!
    refute link.reload.destroyed?

    item.restore
    refute_empty item.reload.links

    item.really_destroy!
    assert_empty Link.where(item_id: item.id)
  end
end
