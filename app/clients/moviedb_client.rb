class MoviedbClient
  include HTTParty
  base_uri 'https://api.themoviedb.org/3'
  default_params api_key: ENV['MOVIEDB_API_KEY']

  IMAGE_BASE_URI = 'https://image.tmdb.org/t/p/w500'

  GENRES = {
    28 =>    "Action & Adventure",
    12 =>    "Action & Adventure",
    10759 => "Action & Adventure",
    16 =>    "Animation",
    35 =>    "Comedy",
    80 =>    "Crime",
    99 =>    "Documentary",
    18 =>    "Drama",
    10751 => "Family",
    10762 => "Kids",
    36 =>    "History",
    27 =>    "Horror",
    10402 => "Music",
    9648 =>  "Mystery",
    10763 => "News",
    10764 => "Reality",
    10749 => "Romance",
    14 =>    "SciFi & Fantasy",
    878 =>   "SciFi & Fantasy",
    10765 => "SciFi & Fantasy",
    10766 => "Soap",
    10767 => "Talk",
    53 =>    "Thriller",
    10770 => "TV Movie",
    10767 => "War & Politics",
    10752 => "War",
    37 =>    "Western"
  }

  def search(query, type: 'movie')
    self.class.get("/search/#{type}", query: { 'query' => query })
  end
end
