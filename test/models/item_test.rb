require 'test_helper'

class ItemTest < ActiveSupport::TestCase

  test "Items must have unique names" do
    user = create(:user)
    label = create(:label, name: 'Music')
    item1 = create(:item, name: 'pigeon', labels: [label])
    item2 = Item.new(name: 'pigeon', labels: [label], user: user)
    item3 = Item.new(name: 'Pigeon', labels: [label], user: user)
    assert item1.valid?
    assert_not item2.valid?
    assert item3.valid?
  end

  test "Items require a non-empty name" do
    user = create(:user)
    label = create(:label, name: 'Music')
    item1 = Item.new(name: '', labels: [label], user: user)
    item2 = Item.new(name: 'singstar adventures', labels: [label], user: user)
    assert_not item1.valid?
    assert item2.valid?
  end

  test ".with_labels(label_ids) returns items that are associated with one of label_ids" do
    label1 = create(:label, name: 'Music')
    label2 = create(:label, name: 'TV')

    i1 = create(:item, name: 'item1', labels: [label1])
    i2 = create(:item, name: 'item2', labels: [label1, label2])
    i3 = create(:item, name: 'item3', labels: [label2])

    assert_equal [i1, i2], Item.with_labels([label1.id]).order(:id)
    assert_equal [i1, i2, i3], Item.with_labels([label1.id, label2.id]).order(:id)
    assert_equal [i2, i3], Item.with_labels([label2.id]).order(:id)

    assert_empty Item.with_labels([43123])
  end

  test ".with_tags(tag_ids) returns items that are associated with one of tag_ids" do
    user = create(:user)

    tag1 = create(:tag, name: 'Low Fi', user: user)
    tag2 = create(:tag, name: 'Space Rock', user: user)

    i1 = create(:item, name: 'item1', tags: ['Low Fi'], user: user)
    i2 = create(:item, name: 'item2', tags: ['Low Fi', 'Space Rock'], user: user)
    i3 = create(:item, name: 'item3', tags: ['Space Rock'], user: user)

    assert_equal [i1, i2], user.items.with_tags([tag1.id]).order(:id)
    assert_equal [i1, i2, i3], user.items.with_tags([tag1.id, tag2.id]).order(:id)
    assert_equal [i2, i3], user.items.with_tags([tag2.id]).order(:id)

    assert_empty user.items.with_tags([43123])
  end

  test '.create_from(scraper_result) sets the user and scraped to true' do
    result = { name: 'Some Item' }
    user = create(:user)
    item = Item.create_from(result, user: user)
    assert item.scraped
    assert_equal 'Some Item', item.name
    assert_equal user, item.user
  end

  test '#update_from(scraper_result) sets scraped to true' do
    item = create(:item, name: 'Hello')
    refute item.scraped

    result = { name: 'Foobar' }
    item.update_from(result)
    assert item.scraped
    assert_equal 'Foobar', item.name
  end
end
