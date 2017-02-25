class ItemsController < ApplicationController
  before_action :set_item,
    only: %i(show update destroy scrape really_destroy restore)

  def index
    @items = if (label_ids = params[:label_ids]).present?
               set_label_ids(label_ids)
               current_user.items.with_labels(current_label_ids)
             else
               reset_label_ids
               current_user.items
             end

    if (tag_ids = params[:tag_ids]).present?
      @items = @items.with_tags(tag_ids)
    end

    @items = if params[:archived]
               @items.only_deleted.order('deleted_at DESC')
             else
               @items.reverse_order
             end

    @items = @items.includes(:labels, :tags)
  end

  def show
    render 'form'
  end

  def create
    item = current_user.items.new item_params.merge(label_ids: current_label_ids)

    if item.save
      # flash[:notice] = 'Item successfully created'
    else
      flash[:alert] = 'Could not create item'
    end
    redirect_to action: :index, label_ids: current_label_id_params, focus_search: true
  end

  def update
    if @item.update_attributes(item_params)
      flash[:notice] = 'Item successfully updated'
      redirect_to action: :index, label_ids: current_label_id_params
    else
    end
  end

  def destroy
    @item.destroy!
    flash[:notice] = 'Item successfully archived'
    redirect_to action: :index, label_ids: current_label_id_params
  end

  def really_destroy
    @item.really_destroy!
    flash[:notice] = 'Item successfully deleted'
    redirect_to action: :index, archived: true
  end

  def restore
    @item.restore
    flash[:notice] = 'Item successfully restored'
    redirect_to @item
  end

  def scrape
    begin
      unless @item.lucky_scrape
        flash[:alert] = 'Could not scrape item'
      end
    rescue SocketError
      flash[:alert] = 'No internet connection'
    end

    redirect_to action: :index, label_ids: current_label_id_params
  end

  private

  def set_item
    @item = current_user.items.with_deleted.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name, :description, :date, :remote_image_url)
  end
end
