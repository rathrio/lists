class AddOriginalNameToItems < ActiveRecord::Migration[6.0]
  def change
    add_column :items, :original_name, :string
    add_index :items, :original_name
  end
end
