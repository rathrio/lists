class CreateLabels < ActiveRecord::Migration[5.0]
  def change
    create_table :labels do |t|
      t.string :name
      t.string :description
      t.string :scraper
    end

    create_table :items_labels, id: false do |t|
      t.belongs_to :item, index: true
      t.belongs_to :label, index: true
    end
  end
end
