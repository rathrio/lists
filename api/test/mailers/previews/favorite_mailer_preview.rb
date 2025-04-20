# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/favorite_mailer
class FavoriteMailerPreview < ActionMailer::Preview
  def email
    item = User.first.items
               .where("rating >= 4")
               .order("RANDOM()")
               .limit(1)
               .first

    FavoriteMailer.with(item:).email
  end
end
