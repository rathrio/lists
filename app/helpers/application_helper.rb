module ApplicationHelper
  def youtube_search_url(query)
    "https://www.youtube.com/results?search_query=#{URI.escape(query)}"
  end

  def pirate_search_url(query)
    "https://thepiratebay.org/search/#{URI.escape(query)}"
  end
end
