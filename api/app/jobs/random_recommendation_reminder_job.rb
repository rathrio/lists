# frozen_string_literal: true

class RandomRecommendationReminderJob < ApplicationJob
  queue_as :default

  def perform
    user = User.find(1)

    random_recommendation = user.items
                                .where.not(recommended_by: nil)
                                .where(status: :todo)
                                .order("RANDOM()")
                                .limit(1)
                                .first

    RecommendationMailer.with(item: random_recommendation).email.deliver_now
  end
end
