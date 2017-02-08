class ItemsController < ApplicationController
  def index
    @items = Item.all.reverse_order
  end

  def show
    @item = Item.find(params[:id])
  end

  def create
    item = Item.new item_params
    result = MovieScraper.new(query: item.name).scrape.first
    item.update_from(result)
    redirect_to action: :index
  end

  private

  def item_params
    params.require(:item).permit(:name)
  end
end
