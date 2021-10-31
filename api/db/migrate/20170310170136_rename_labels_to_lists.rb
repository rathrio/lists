class RenameLabelsToLists < ActiveRecord::Migration[5.0]
  def up
    rename_table :labels, :lists
    rename_table :items_labels, :items_lists
    rename_column :items_lists, :label_id, :list_id

    add_reference :items, :list, index: true
    Item.find_each do |item|
      item.update(list_id: item.list_ids.first)
    end
  end

  def down
    rename_table :lists, :labels
    remove_column :items, :label_id
  end
end
