class ListsController < ApplicationController
  def index
    lists = current_user.lists
    render json: lists
  end

  def create
    @list = current_user.lists.new

    if @list.update(list_params)
      flash[:notice] = 'List successfully created'
    else
      flash[:alert] = 'Could not create list'
    end

    redirect_to action: :index
  end

  def destroy
    @list = current_user.lists.find(params[:id])
    @list.destroy!
    flash[:notice] = 'List successfully deleted'
    redirect_to action: :index
  end

  def edit
    @list = current_user.lists.find(params[:id])
    render 'form'
  end

  def update
    @list = current_user.lists.find(params[:id])

    if @list.update(list_params)
      flash[:notice] = 'List successfully updated'
      redirect_to edit_list_path(@list)
    else
      flash[:alert] = 'Could not update list'
      render 'form'
    end
  end

  private

  def list_params
    params.require(:list).permit(:name, :description, :fa_icon, :scraper)
  end
end
