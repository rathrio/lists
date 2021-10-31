class DiscogsClient
  include HTTParty
  base_uri 'https://api.discogs.com'
  default_params key: ENV['DISCOGS_API_KEY'], secret: ENV['DISCOGS_API_SECRET']
  headers('User-Agent' => 'lists.rathr.io')

  def search(query, type: 'release')
    return [] if query.blank?

    artist, release_title = query.split('-').map(&:strip)
    self.class.get(
      "/database/search",
      query: { release_title: release_title, artist: artist, type: type }
    )
  end
end
