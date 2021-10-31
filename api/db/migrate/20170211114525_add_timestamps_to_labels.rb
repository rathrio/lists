class AddTimestampsToLabels < ActiveRecord::Migration[5.0]
  def change
    add_column :labels, :created_at, :datetime
    add_column :labels, :updated_at, :datetime

    add_column :tags, :created_at, :datetime
    add_column :tags, :updated_at, :datetime
  end
end
