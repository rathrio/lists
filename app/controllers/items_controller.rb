class ItemsController < ApplicationController
  def index
    @items = if (label_ids = params[:label_ids]).present?
               set_label_ids(label_ids)
               Item.with_labels(current_label_ids)
             else
               reset_label_ids
               Item.all
             end

    @items = if params[:archived]
               @items.only_deleted.order('deleted_at DESC')
             else
               @items.includes(:labels, :tags).all.reverse_order
             end
  end

  def show
    @item = Item.with_deleted.find(params[:id])
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
      redirect_to action: :index, label_ids: current_label_id_params
    else
    end
  end

  def destroy
    @item = Item.find(params[:id])
    @item.destroy!
    flash[:notice] = 'Item successfully archived'
    redirect_to action: :index, label_ids: current_label_id_params
  end

  def really_destroy
    @item = Item.with_deleted.find(params[:id])
    @item.really_destroy!
    flash[:notice] = 'Item successfully deleted'
    redirect_to action: :index, archived: true
  end

  def restore
    @item = Item.with_deleted.find(params[:id])
    @item.restore
    flash[:notice] = 'Item successfully restored'
    redirect_to @item
  end

  def scrape
    @item = Item.find(params[:id])

    begin
      unless @item.lucky_scrape
        flash[:alert] = 'Could not scrape item'
      end
    rescue SocketError
      flash[:alert] = 'No internet connection'
    end

    redirect_to action: :index, label_ids: current_label_id_params
  end

  def scrape_all

    begin
      Item.lucky_scrape(current_label_ids)
    rescue SocketError
      flash[:alert] = 'No internet connection'
    end
    redirect_to action: :index, label_ids: current_label_id_params
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :date)
  end
end
