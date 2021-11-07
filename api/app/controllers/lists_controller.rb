class ListsController < ApplicationController
  def index
    lists = current_user.lists

    if stale?(lists)
      json = Rails.cache.fetch(lists.cache_key, expires_in: 30.days) do
        lists.to_json
      end

      render json: json
    end
  end
end
