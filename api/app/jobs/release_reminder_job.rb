# frozen_string_literal: true

class ReleaseReminderJob < ApplicationJob
  queue_as :default

  def perform
    user = User.find(1)

    user.items.where(date: Date.today).each do |item|
      ReleaseMailer.with(item:).email.deliver_now
    end
  end
end
