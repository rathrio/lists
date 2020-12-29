class AddLanguageToItems < ActiveRecord::Migration[6.0]
  def change
    add_column :items, :language, :string
    add_index :items, :language
  end
end
