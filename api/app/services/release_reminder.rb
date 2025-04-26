# frozen_string_literal: true

class ReleaseReminder
  def self.run(user)
    user.items.where(date: Date.today).each do |item|
      ReleaseMailer.with(item:).email.deliver_now
    end
  end
end
