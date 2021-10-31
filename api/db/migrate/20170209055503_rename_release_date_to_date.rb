class RenameReleaseDateToDate < ActiveRecord::Migration[5.0]
  def change
    rename_column :items, :release_date, :date
  end
end
