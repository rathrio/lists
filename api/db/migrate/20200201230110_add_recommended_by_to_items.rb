class AddRecommendedByToItems < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :recommended_by, :string
    add_index :items, :recommended_by
  end
end
