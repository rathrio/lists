module ApplicationHelper
  def youtube_search_url(query)
    "https://www.youtube.com/results?search_query=#{URI.escape(query)}"
  end

  def pirate_search_url(query)
    "https://thepiratebay.org/search/#{URI.escape(query)}"
  end

  def google_search_url(query)
    "https://www.google.ch/search?q=#{URI.escape(query)}"
  end

  def netflix_search_url(query)
    "https://www.netflix.com/search?q=#{URI.escape(query)}"
  end
end
