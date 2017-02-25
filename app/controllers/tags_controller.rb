class TagsController < ApplicationController
  def index
    @tags = current_user.tags.order(:name)
  end

  def create
  end

  def destroy
  end

  def edit
  end

  def update
  end

  private
end
