# frozen_string_literal: true

class ProwlarrClient
  include HTTParty
  base_uri ENV.fetch("PROWLARR_HOST")
  default_timeout 120

  MOVIE_CATEGORIES = [2000, 2010, 2020, 2030, 2040, 2045, 2050, 2060].freeze
  TV_CATEGORIES = [5000, 5010, 5020, 5030, 5040, 5045, 5050, 5060, 5070, 5080].freeze

  PUBLIC_TRACKERS = [
    "udp://tracker.opentrackr.org:1337/announce",
    "udp://open.demonii.com:1337/announce",
    "udp://tracker.openbittorrent.com:6969/announce",
    "udp://exodus.desync.com:6969/announce"
  ].freeze

  QUALITY_SCORES = {
    "2160p" => 100, "4k" => 100, "uhd" => 100,
    "1080p" => 80,
    "720p" => 60,
    "480p" => 40,
    "bluray" => 20, "blu-ray" => 20, "bdrip" => 20,
    "web-dl" => 15, "webdl" => 15, "webrip" => 12,
    "hdtv" => 10,
    "x265" => 5, "hevc" => 5,
    "x264" => 3,
    "remux" => 25
  }.freeze

  def initialize
    @api_key = ENV.fetch("PROWLARR_API_KEY")
  end

  # @param query [String] search query (e.g. movie/show name)
  # @param year [Integer, nil] filter results by year in title
  # @param type [Symbol] :movie or :tv
  # @param limit [Integer] max results to return
  # @return [Array<Hash>] torrent links with title, size, seeders, etc.
  def magnet_links(query, year: nil, type: :movie, limit: 10)
    results = search(query, year: year, type: type)
    sorted = results.sort_by { |r| -(r["seeders"] || 0) }

    sorted.first(limit).map do |r|
      magnet = extract_magnet(r)

      {
        "title" => r["title"],
        "size" => format_size(r["size"]),
        "size_bytes" => r["size"],
        "seeders" => r["seeders"],
        "leechers" => r["leechers"],
        "indexer" => r["indexer"],
        "quality" => quality_score(r["title"]),
        "magnet" => magnet,
        "info_hash" => r["infoHash"]
      }
    end
  end

  private

  def search(query, year: nil, type: :movie)
    categories = type == :tv ? TV_CATEGORIES : MOVIE_CATEGORIES
    category_params = categories.map { |c| "categories=#{c}" }.join("&")

    response = self.class.get(
      "/api/v1/search",
      query: { query: query, type: type == :tv ? "tvsearch" : "movie" },
      headers: { "X-Api-Key" => @api_key },
      query_string_normalizer: ->(q) { "#{q.to_query}&#{category_params}" }
    )

    results = response.parsed_response
    return [] unless results.is_a?(Array)

    # Filter by year in title
    results = results.select { |r| r["title"]&.include?(year.to_s) } if year

    # Score by title relevance
    query_words = query.downcase.split(/\s+/)
    results.each do |r|
      title_lower = (r["title"] || "").downcase
      r["_relevance"] = query_words.count { |w| title_lower.include?(w) }
    end

    # Filter low relevance (less than half query words)
    min_relevance = (query_words.length / 2.0).ceil
    results.select { |r| r["_relevance"] >= min_relevance }
  end

  def extract_magnet(result)
    # Priority: direct magnet > resolved magnet > built from info_hash
    magnet = result["magnetUrl"] if result["magnetUrl"]&.start_with?("magnet:")
    magnet ||= result["downloadUrl"] if result["downloadUrl"]&.start_with?("magnet:")
    magnet ||= resolve_magnet(result["downloadUrl"]) if result["downloadUrl"]
    magnet ||= build_magnet(result["infoHash"], result["title"])
    magnet
  end

  def resolve_magnet(download_url)
    return nil unless download_url

    uri = URI(download_url)
    http = Net::HTTP.new(uri.hostname, uri.port)
    http.open_timeout = 5
    http.read_timeout = 5

    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    if %w[301 302].include?(response.code) && response["location"]&.start_with?("magnet:")
      response["location"]
    elsif response.body&.start_with?("magnet:")
      response.body
    end
  rescue StandardError => e
    Rails.logger.warn("Failed to resolve magnet from #{download_url}: #{e.message}")
    nil
  end

  def build_magnet(info_hash, title = nil)
    return nil unless info_hash

    magnet = "magnet:?xt=urn:btih:#{info_hash}"
    magnet += "&dn=#{ERB::Util.url_encode(title)}" if title
    PUBLIC_TRACKERS.each { |tr| magnet += "&tr=#{ERB::Util.url_encode(tr)}" }
    magnet
  end

  def quality_score(title)
    return 0 unless title

    title_lower = title.downcase
    QUALITY_SCORES.sum { |pattern, score| title_lower.include?(pattern) ? score : 0 }
  end

  def format_size(bytes)
    return "?" unless bytes

    units = %w[B KB MB GB TB]
    exp = (Math.log(bytes) / Math.log(1024)).to_i
    exp = units.length - 1 if exp > units.length - 1
    format("%.2f %s", bytes.to_f / (1024**exp), units[exp])
  end
end
