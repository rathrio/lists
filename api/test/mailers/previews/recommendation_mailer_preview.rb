# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/recommendation_mailer
class RecommendationMailerPreview < ActionMailer::Preview
  def email
    item = User.first.items
               .where.not(recommended_by: nil)
               .where(status: :todo)
               .order("RANDOM()")
               .limit(1)
               .first

    RecommendationMailer.with(item:).email
  end
end
