class ItemsController < ApplicationController
  def index
    @items = Item.all.reverse_order
  end

  def show
    @item = Item.find(params[:id])
    render 'form'
  end

  def create
    item = Item.new item_params
    result = MovieScraper.new(query: item.name).scrape.first
    item.update_from(result)
    redirect_to action: :index
  end

  def update
    @item = Item.find(params[:id])

    if @item.update_attributes(item_params)
      flash[:notice] = 'Item successfully updated'
      redirect_to @item
    else
    end
  end

  def destroy
    @item = Item.find(params[:id])
    @item.destroy!
    flash[:notice] = 'Item successfully deleted'
    redirect_to action: :index
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :release_date)
  end
end
