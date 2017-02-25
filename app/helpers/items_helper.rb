module ItemsHelper
  def cache_key_for_items(items)
    [current_user.id, @items, current_label_id_params, params[:tag_ids], params[:archived]]
  end
end
