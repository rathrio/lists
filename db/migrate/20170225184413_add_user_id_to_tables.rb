class AddUserIdToTables < ActiveRecord::Migration[5.0]
  def change
    add_reference :items, :user, index: true, foreign_key: true
    add_reference :labels, :user, index: true, foreign_key: true
    add_reference :tags, :user, index: true, foreign_key: true
  end
end
