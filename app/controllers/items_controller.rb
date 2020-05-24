# frozen_string_literal: true

class ItemsController < ApplicationController
  before_action :set_item, only: %i(
    show
    update
    destroy
    scrape
    really_destroy
    restore
    toggle_status
    update_rating
  )

  def index
    @items = if (list_ids = params[:list_ids]).present?
               set_list_ids(list_ids)
               current_user.items.in_lists(current_list_ids)
             else
               reset_list_ids
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
  end

  def root
    first_list_id = current_user.list_ids.first
    redirect_to items_path(list_ids: first_list_id)
  end

  def show
    render 'form'
  end

  def create
    item = current_user.items.new item_params.merge(list_id: current_list_id)

    if item.save
      flash[:notice] = 'Item successfully created'
    else
      error_message = item.errors.full_messages.to_sentence
      flash[:alert] = error_message
    end

    redirect_to action: :index, list_ids: current_list_id_params, focus_search: true
  end

  def update
    attributes = item_params

    if item_params['tags'].present?
      attributes = item_params.merge(
        'tags' => item_params['tags'].split(',').map(&:strip)
      )
    end

    if @item.update(attributes)
      render json: @item.to_json
    else
      render json: { message: 'Validation failed', errors: @order.errors }, status: 400
    end
  end

  def toggle_status
    next_status_index = @item.next_status_index
    @item.update!(status: next_status_index)
    render json: @item.to_json
  end

  def update_rating
    rating = params.fetch(:rating)
    @item.update!(rating: rating)
    render json: @item.to_json
  end

  def destroy
    @item.destroy!
    render json: @item.to_json
  end

  def really_destroy
    @item.really_destroy!
    render json: @item.to_json
  end

  def restore
    @item.restore
    render json: @item.to_json
  end

  private

  def set_item
    @item = current_user.items.with_deleted.find(params[:id])
  end

  def item_params
    params.require(:item).permit(
      :name,
      :description,
      :date,
      :first_done_at,
      :remote_image_url,
      :rating,
      :tags,
      :recommended_by
    )
  end
end
