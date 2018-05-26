class AddStatusToItems < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :status, :integer, default: 0
    add_index :items, :status
  end
end
