# frozen_string_literal: true

class ReleaseMailer < ApplicationMailer
  def email
    @item = params[:item]
    @cover_url = @item.public_image_url
    user = @item.user
    subject = "\"#{@item.name}\" is out now!"
    mail(to: user.email, subject:)
  end
end
