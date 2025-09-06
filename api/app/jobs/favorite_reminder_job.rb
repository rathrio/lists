# frozen_string_literal: true

class FavoriteReminderJob < ApplicationJob
  queue_as :default

  def perform
    user = User.find(1)
    random_favorite = user.items
                      .where("rating >= 4")
                      .order("RANDOM()")
                      .limit(1)
                      .first

    FavoriteMailer.with(item: random_favorite).email.deliver_now
  end
end
