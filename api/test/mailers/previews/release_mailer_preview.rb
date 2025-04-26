# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/release_mailer
class ReleaseMailerPreview < ActionMailer::Preview
  def email
    item = User.first.items
               .order("RANDOM()")
               .limit(1)
               .first

    ReleaseMailer.with(item:).email
  end
end
