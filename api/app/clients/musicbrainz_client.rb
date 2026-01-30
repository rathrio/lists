class MusicbrainzClient
  include HTTParty
  base_uri "https://musicbrainz.org/ws/2"
  headers("User-Agent" => "Lists/1.0 (lists.rathr.io)")

  COVER_ART_BASE_URI = "https://coverartarchive.org/release"

  def search(query, filter_values: [])
    return [] if query.blank?

    sleep 1 # MusicBrainz rate limit: 1 request/second

    artist, release = parse_query(query)
    lucene_query = build_lucene_query(artist, release)

    response = self.class.get(
      "/release",
      query: { query: lucene_query, fmt: "json", limit: 25 }
    )

    response["releases"].to_a
  end

  def cover_art_url(mbid)
    "#{COVER_ART_BASE_URI}/#{mbid}/front-500"
  end

  private

  def parse_query(query)
    if query.include?("-")
      parts = query.split("-", 2).map(&:strip)
      [parts[0], parts[1]]
    else
      [nil, query.strip]
    end
  end

  def build_lucene_query(artist, release)
    parts = []
    parts << "artist:\"#{artist}\"" if artist.present?
    parts << "release:\"#{release}\"" if release.present?
    parts.join(" AND ")
  end
end
