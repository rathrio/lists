module ApplicationHelper
  def current_label_ids
    session[:label_ids] ||= []
  end

  def set_label_ids(ids)
    session[:label_ids] = ids
  end
end
