# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  def email
    notification = params[:notification]
    user = notification.user
    mail(to: user.email, subject: notification.subject, body: notification.body)
  end
end
