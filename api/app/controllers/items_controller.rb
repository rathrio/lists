# frozen_string_literal: true

class ItemsController < ApplicationController
  before_action :set_item, only: %i(
                             show
                             refresh_metadata
                             availability
                             request_download
                             metadata
                             update
                             destroy
                             really_destroy
                             restore
                             toggle_status
                             update_rating
                           )

  def index
    items = current_user.lists.find(params[:list_id]).items

    if stale?(items)
      json = Rails.cache.fetch(items.cache_key, expires_in: 30.days) do
        items.includes(:list, :tags).to_json(except: :metadata)
      end

      render json: json
    end
  end

  def show
    if stale?(@item)
      render json: @item
    end
  end

  def refresh_metadata
    @item.scrape_and_update(fields: [:metadata])
    render json: @item
  end

  # Jellyseerr availability of the item, looked up live over the tailnet.
  # 204 means "nothing to show" — either the item can't be matched (no TMDB
  # id) or Jellyseerr is unreachable. Neither is an error the UI should
  # surface.
  def availability
    return head :no_content unless @item.requestable?

    render json: @item.availability
  rescue StandardError => e
    Rails.logger.warn("Jellyseerr availability for item #{@item.id} failed: #{e.message}")
    head :no_content
  end

  def request_download
    return head :no_content unless @item.requestable?

    render json: @item.request_download!
  rescue StandardError => e
    Rails.logger.error("Jellyseerr request for item #{@item.id} failed: #{e.message}")
    render json: { message: "Request failed" }, status: 502
  end

  def archived
    items = current_user.items.only_deleted.order("deleted_at DESC")

    if stale?(items)
      json = Rails.cache.fetch(items.cache_key, expires_in: 30.days) do
        items.includes(:list, :tags).to_json(except: :metadata)
      end

      render json: json
    end
  end

  def journal
    items = current_user.items
      .where(status: Item.statuses[:done])
      .where.not(first_done_at: nil)
      .order("first_done_at DESC")

    if stale?(items)
      json = Rails.cache.fetch(items.cache_key, expires_in: 30.days) do
        items.includes(:list, :tags).to_json(except: :metadata)
      end

      render json: json
    end
  end

  def update
    attributes = item_params

    # "Horror, Comedy" => ["Horror", "Comedy"]
    if item_params["tags"].present?
      attributes = item_params.merge(
        "tags" => item_params["tags"].split(",").map(&:strip),
      )
    end

    if @item.update(attributes)
      render json: @item.to_json
    else
      render json: { message: "Validation failed", errors: @order.errors }, status: 400
    end
  end

  def toggle_status
    @item.update!(status: @item.next_status_index)
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
      :original_name,
      :description,
      :date,
      :first_done_at,
      :image,
      :remote_image_url,
      :rating,
      :tags,
      :recommended_by,
      :language,
      :notes
    )
  end
end
