class CreateNotes < ActiveRecord::Migration[5.0]
  def change
    create_table :notes do |t|
      t.text :text
      t.references :item, foreign_key: true

      t.timestamps
    end
  end
end
