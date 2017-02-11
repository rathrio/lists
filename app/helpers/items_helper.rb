module ItemsHelper
  def cache_key_for_items(items)
    [@items, current_label_id_params, params[:tag_ids], params[:archived]]
  end
end
