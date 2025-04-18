class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.string :subject, null: false
      t.string :body
      t.string :key, null: false
      t.integer :email_status, index: true, default: 0, null: false
      t.belongs_to :user, index: true, null: false

      t.timestamps
    end

    add_index :notifications, :key, unique: true
  end
end
