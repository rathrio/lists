# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "Lists <lists@rathr.io>"
  layout "mailer"
end
