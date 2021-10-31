class AddNewBookLabelToUsers < ActiveRecord::Migration[5.0]
  def change
    User.all.each do |user|
      user.labels.find_or_create_by(name: 'Books', scraper: 'BookScraper', fa_icon: 'book')
    end
  end
end
