# frozen_string_literal: true

class RecommendationMailer < ApplicationMailer
  def email
    @item = params[:item]
    @cover_url = @item.public_image_url
    user = @item.user
    recommender = @item.recommended_by
    subject = "#{recommender} recommended the #{@item.year} #{@item.list.name.downcase.singularize} \"#{@item.name}\""
    mail(to: user.email, subject:)
  end
end
