# frozen_string_literal: true

class TvShowsWithNewEpisodesJob < ApplicationJob
  queue_as :default

  def perform(*users)
    users.each do |user|
      NotifyUserAboutNewEpisodes.run(user)
    end
  end
end
