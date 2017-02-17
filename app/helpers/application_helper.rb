module ApplicationHelper
  def youtube_search_url(query)
    "https://www.youtube.com/results?search_query=#{URI.escape(query)}"
  end
end
