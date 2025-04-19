# frozen_string_literal: true

class RecommendationMailer < ApplicationMailer
  def email
    @item = params[:item]
    @cover_url = public_image_url(@item)
    user = @item.user
    recommender = @item.recommended_by
    subject = "#{recommender} recommends the #{@item.year} #{@item.list.name.downcase.singularize} \"#{@item.name}\""
    mail(to: user.email, subject:)
  end

  def public_image_url(item)
    url = item.image&.url
    Rails.env.production? ? "https://lists.rathr.io/api/#{url}" : "http://localhost:3000/#{url}"
  end
end
