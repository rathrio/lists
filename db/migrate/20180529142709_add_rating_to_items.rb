class AddRatingToItems < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :rating, :float
    add_index :items, :rating
  end
end
