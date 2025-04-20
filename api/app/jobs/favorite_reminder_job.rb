# frozen_string_literal: true

class FavoriteReminderJob < ApplicationJob
  queue_as :default

  def perform
    FavoriteReminder.run(User.first)
  end
end
