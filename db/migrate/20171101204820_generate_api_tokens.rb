class GenerateApiTokens < ActiveRecord::Migration[5.1]
  def up
    User.find_each do |user|
      user.regenerate_api_token
    end
  end

  def down
  end
end
