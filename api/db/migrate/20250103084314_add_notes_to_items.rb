class AddNotesToItems < ActiveRecord::Migration[8.0]
  def change
    add_column :items, :notes, :string
  end
end
