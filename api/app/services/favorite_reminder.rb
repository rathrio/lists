# frozen_string_literal: true

class FavoriteReminder
  def self.run(user)
    random_favorite = user.items
                          .where("rating >= 4")
                          .order("RANDOM()")
                          .limit(1)
                          .first

    FavoriteMailer.with(item: random_favorite).email.deliver_now
  end
end
