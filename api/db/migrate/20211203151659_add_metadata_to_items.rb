class AddMetadataToItems < ActiveRecord::Migration[6.1]
  def change
    add_column :items, :backdrop_image, :string
    add_column :items, :metadata, :jsonb, default: {}
    add_index :items, :metadata
  end
end
