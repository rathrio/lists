class ItemsController < ApplicationController
  def index
    @items = if (label_ids = params[:label_ids]).present?
               set_label_ids(label_ids)
               Item.with_labels(current_label_ids)
             else
               reset_label_ids
               Item.all
             end

    @items = @items.includes(:labels).all.reverse_order
  end

  def show
    @item = Item.find(params[:id])
    render 'form'
  end

  def create
    item = Item.new item_params.merge(label_ids: current_label_ids)

    if item.save
      # flash[:notice] = 'Item successfully created'
    else
      flash[:alert] = 'Could not create item'
    end
    redirect_to action: :index, label_ids: current_label_id_params
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
    redirect_to action: :index, label_ids: current_label_id_params
  end

  def scrape
    @item = Item.find(params[:id])
    scraper = @item.labels.first&.default_scraper

    if scraper.nil?
      flash[:alert] = 'Could not scrape item'
    else
      result = scraper.new(query: @item.name).scrape.first
      if result
        @item.update_from(result)
        # flash[:notice] = 'Scrape complete'
      end
    end

    redirect_to action: :index, label_ids: current_label_id_params
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :release_date)
  end
end
