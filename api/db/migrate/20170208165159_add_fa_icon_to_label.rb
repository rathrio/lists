class AddFaIconToLabel < ActiveRecord::Migration[5.0]
  def change
    add_column :labels, :fa_icon, :string
  end
end
