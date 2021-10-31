class AddFirstDoneAtToItems < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :first_done_at, :date
    add_index :items, :first_done_at
  end
end
