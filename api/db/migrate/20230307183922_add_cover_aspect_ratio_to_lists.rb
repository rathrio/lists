class AddCoverAspectRatioToLists < ActiveRecord::Migration[7.0]
  def change
    add_column :lists, :cover_aspect_ratio, :string
  end
end
