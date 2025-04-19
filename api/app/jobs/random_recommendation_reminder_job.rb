# frozen_string_literal: true

class RandomRecommendationReminderJob < ApplicationJob
  queue_as :default

  def perform
    RandomRecommendationReminder.run(User.find(1))
  end
end
