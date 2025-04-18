# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/notification_mailer
class NotificationMailerPreview < ActionMailer::Preview
  def email
    NotificationMailer.with(notification: Notification.last).email
  end
end
