# frozen_string_literal: true

class ReleaseReminderJob < ApplicationJob
  queue_as :default

  def perform
    ReleaseReminder.run(User.find(1))
  end
end
