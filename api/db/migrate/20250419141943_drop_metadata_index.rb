class DropMetadataIndex < ActiveRecord::Migration[8.0]
  def change
    remove_index :items, name: "index_items_on_metadata"
  end
end
