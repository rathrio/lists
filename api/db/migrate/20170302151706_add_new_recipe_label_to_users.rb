class AddNewRecipeLabelToUsers < ActiveRecord::Migration[5.0]
  def change
    User.all.each do |user|
      Label.create_defaults user
    end
  end
end
