class CreateItems < ActiveRecord::Migration[5.0]
  def change
    create_table :items do |t|
      t.string :name
      t.string :description
      t.integer :quantity, default: 0
      t.boolean :scraped, default: false
      t.date :release_date

      t.timestamps
    end
    add_index :items, :name
  end
end
