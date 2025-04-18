# frozen_string_literal: true

class NotifyUserAboutNewEpisodesJob < ApplicationJob
  queue_as :default

  def perform
    NotifyUserAboutNewEpisodes.run(User.find(1))
  end
end
