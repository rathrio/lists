class DropItemsLists < ActiveRecord::Migration[5.1]
  def up
    drop_table :items_lists
  end

  def down
    create_table "items_lists", id: false, force: :cascade do |t|
      t.integer "item_id"
      t.integer "list_id"
      t.index ["item_id"], name: "index_items_lists_on_item_id", using: :btree
      t.index ["list_id"], name: "index_items_lists_on_list_id", using: :btree
    end
  end
end
