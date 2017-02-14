module ApplicationHelper
  def current_label_ids
    session[:label_ids] ||= []
  end

  def set_label_ids(ids)
    session[:label_ids] = ids
  end

  def youtube_search_url(query)
    "https://www.youtube.com/results?search_query=#{URI.escape(query)}"
  end
end
