require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  test ".with_labels(label_ids) returns items that are associated with one of label_ids" do
    label1 = Label.create!(name: 'Music')
    label2 = Label.create!(name: 'TV')

    i1 = Item.create!(name: 'item1', labels: [label1])
    i2 = Item.create!(name: 'item2', labels: [label1, label2])
    i3 = Item.create!(name: 'item3', labels: [label2])

    assert_equal [i1, i2], Item.with_labels([label1.id]).order(:id)
    assert_equal [i1, i2, i3], Item.with_labels([label1.id, label2.id]).order(:id)
    assert_equal [i2, i3], Item.with_labels([label2.id]).order(:id)

    assert_empty Item.with_labels([43123])
  end

  test ".with_tags(tag_ids) returns items that are associated with one of tag_ids" do
    tag1 = Tag.create!(name: 'Low Fi')
    tag2 = Tag.create!(name: 'Space Rock')

    i1 = Item.create!(name: 'item1', tags: ['Low Fi'])
    i2 = Item.create!(name: 'item2', tags: ['Low Fi', 'Space Rock'])
    i3 = Item.create!(name: 'item3', tags: ['Space Rock'])

    assert_equal [i1, i2], Item.with_tags([tag1.id]).order(:id)
    assert_equal [i1, i2, i3], Item.with_tags([tag1.id, tag2.id]).order(:id)
    assert_equal [i2, i3], Item.with_tags([tag2.id]).order(:id)

    assert_empty Item.with_tags([43123])
  end

  test '.create_from(scraper_result) sets scraped to true' do
    result = { name: 'Some Item' }
    item = Item.create_from(result)
    assert item.scraped
    assert_equal 'Some Item', item.name
  end

  test '#update_from(scraper_result) sets scraped to true' do
    item = Item.create(name: 'Hello')
    refute item.scraped

    result = { name: 'Foobar' }
    item.update_from(result)
    assert item.scraped
    assert_equal 'Foobar', item.name
  end
end
