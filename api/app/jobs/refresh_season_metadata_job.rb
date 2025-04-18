# frozen_string_literal: true

class RefreshSeasonMetadataJob < ApplicationJob
  queue_as :default

  def perform
    RefreshSeasonMetadata.run(User.find(1))
  end
end
