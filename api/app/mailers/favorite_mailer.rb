# frozen_string_literal: true

class FavoriteMailer < ApplicationMailer
  def email
    @item = params[:item]
    @cover_url = @item.public_image_url
    user = @item.user
    subject = "Remember \"#{@item.name}\"?"
    mail(to: user.email, subject:)
  end
end
