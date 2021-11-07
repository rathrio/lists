class ListsController < ApplicationController
  def index
    lists = current_user.lists
    render json: lists
  end
end
