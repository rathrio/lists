#!/usr/bin/env ruby
# frozen_string_literal: true

# Demo script: Search for movie torrents via Prowlarr API
#
# Setup:
#   1. Start Prowlarr: docker compose -f docker-compose.dev.yml up prowlarr
#   2. Open http://localhost:9696 and complete initial setup
#   3. Add indexers (Settings > Indexers > Add)
#   4. Get your API key (Settings > General > API Key)
#   5. Run: PROWLARR_API_KEY=your_key ruby scripts/prowlarr_search.rb "Inception" 2010

require "net/http"
require "json"
require "uri"
require "rexml/document"

class ProwlarrClient
  DEFAULT_API_KEY = "dev-prowlarr-api-key-12345"

  def initialize(host: "localhost", port: 9696, api_key: nil)
    @host = host
    @port = port
    @api_key = api_key || ENV.fetch("PROWLARR_API_KEY", DEFAULT_API_KEY)
  end

  # Torznab categories
  MOVIE_CATEGORIES = [2000, 2010, 2020, 2030, 2040, 2045, 2050, 2060].freeze
  TV_CATEGORIES = [5000, 5010, 5020, 5030, 5040, 5045, 5050, 5060, 5070, 5080].freeze

  # Quality patterns for parsing release names
  QUALITY_SCORES = {
    "2160p" => 100, "4k" => 100, "uhd" => 100,
    "1080p" => 80,
    "720p" => 60,
    "480p" => 40,
    "bluray" => 20, "blu-ray" => 20, "bdrip" => 20,
    "web-dl" => 15, "webdl" => 15, "webrip" => 12,
    "hdtv" => 10,
    "x265" => 5, "hevc" => 5,  # Efficient codec bonus
    "x264" => 3,
    "remux" => 25,  # High quality
  }.freeze

  # Language search keywords (appended to query)
  LANGUAGE_KEYWORDS = {
    "german" => %w[German Deutsch],
    "french" => %w[French Français],
    "spanish" => %w[Spanish Español],
    "italian" => %w[Italian Italiano],
    "japanese" => %w[Japanese],
    "korean" => %w[Korean],
  }.freeze

  # Patterns to identify language/dub in release titles
  LANGUAGE_PATTERNS = {
    "german" => /\b(german|deutsch|ger|dub\.ger|\.ger\.|multi[^)]*ger)\b/i,
    "french" => /\b(french|français|fre|vf|vff|multi[^)]*fre)\b/i,
    "spanish" => /\b(spanish|español|spa|latino|multi[^)]*spa)\b/i,
    "italian" => /\b(italian|italiano|ita|multi[^)]*ita)\b/i,
    "japanese" => /\b(japanese|jpn|jap)\b/i,
    "korean" => /\b(korean|kor)\b/i,
  }.freeze

  # Search using Prowlarr's native API
  # Note: Most public indexers only support text search, not IMDB/TMDB ID
  # @param language [String, nil] Language code (e.g., "german") to search for dubs
  def search(query, year: nil, type: :movie, language: nil)
    # Append language keywords to query if specified
    search_query = if language && LANGUAGE_KEYWORDS[language.downcase]
                     "#{query} #{LANGUAGE_KEYWORDS[language.downcase].first}"
                   else
                     query
                   end

    params = { query: search_query }
    params[:type] = type == :tv ? "tvsearch" : "movie"

    uri = URI("http://#{@host}:#{@port}/api/v1/search")

    # Categories need to be passed as separate parameters
    categories = type == :tv ? TV_CATEGORIES : MOVIE_CATEGORIES
    category_params = categories.map { |c| "categories=#{c}" }.join("&")
    base_query = URI.encode_www_form(params)
    uri.query = "#{base_query}&#{category_params}"

    request = Net::HTTP::Get.new(uri)
    request["X-Api-Key"] = @api_key

    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(request)
    end

    results = JSON.parse(response.body)
    results = [] unless results.is_a?(Array)

    # Filter by year in title
    results = results.select { |r| r["title"]&.include?(year.to_s) } if year

    # Filter by language pattern in title if language specified
    if language && LANGUAGE_PATTERNS[language.downcase]
      results = results.select { |r| r["title"]&.match?(LANGUAGE_PATTERNS[language.downcase]) }
    end

    # Score results by title relevance (use original query, not language-modified one)
    query_words = query.downcase.split(/\s+/)
    results.each do |r|
      title_lower = (r["title"] || "").downcase
      # Count how many query words appear in title
      r["_relevance"] = query_words.count { |w| title_lower.include?(w) }
    end

    # Filter out results with low relevance (less than half the query words)
    min_relevance = (query_words.length / 2.0).ceil
    results.select { |r| r["_relevance"] >= min_relevance }
  end

  # Calculate quality score from release title
  def quality_score(title)
    return 0 unless title

    title_lower = title.downcase
    QUALITY_SCORES.sum { |pattern, score| title_lower.include?(pattern) ? score : 0 }
  end

  # Get all configured indexers
  def indexers
    uri = URI("http://#{@host}:#{@port}/api/v1/indexer")
    request = Net::HTTP::Get.new(uri)
    request["X-Api-Key"] = @api_key

    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(request)
    end

    JSON.parse(response.body)
  end

  # Extract magnet links from search results
  # sort_by: :seeders (default), :quality, :relevance, :size
  def magnet_links(query, year: nil, type: :movie, limit: 10, sort_by: :seeders, language: nil)
    results = search(query, year: year, type: type, language: language)

    # Sort by preference
    sorted = case sort_by
             when :quality
               results.sort_by { |r| [-quality_score(r["title"]), -(r["seeders"] || 0)] }
             when :relevance
               results.sort_by { |r| [-(r["_relevance"] || 0), -(r["seeders"] || 0)] }
             when :size
               results.sort_by { |r| -(r["size"] || 0) }
             else # :seeders
               results.sort_by { |r| -(r["seeders"] || 0) }
             end

    sorted.first(limit).map do |r|
      magnet = r["magnetUrl"]
      magnet ||= r["downloadUrl"] if r["downloadUrl"]&.start_with?("magnet:")
      magnet ||= resolve_magnet(r["downloadUrl"]) if r["downloadUrl"]

      {
        title: r["title"],
        size: format_size(r["size"]),
        size_bytes: r["size"],
        seeders: r["seeders"],
        leechers: r["leechers"],
        indexer: r["indexer"],
        quality: quality_score(r["title"]),
        relevance: r["_relevance"],
        magnet: magnet,
        info_hash: r["infoHash"]
      }
    end
  end

  # Follow Prowlarr download URL to get actual magnet
  def resolve_magnet(download_url)
    return nil unless download_url

    uri = URI(download_url)
    http = Net::HTTP.new(uri.hostname, uri.port)
    http.open_timeout = 5
    http.read_timeout = 5

    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)

    # Check for redirect to magnet (301/302)
    if %w[301 302].include?(response.code) && response["location"]&.start_with?("magnet:")
      response["location"]
    elsif response.body&.start_with?("magnet:")
      response.body
    else
      download_url # Return original as fallback
    end
  rescue StandardError => e
    download_url
  end

  private

  def format_size(bytes)
    return "?" unless bytes

    units = %w[B KB MB GB TB]
    exp = (Math.log(bytes) / Math.log(1024)).to_i
    exp = units.length - 1 if exp > units.length - 1
    format("%.2f %s", bytes.to_f / (1024**exp), units[exp])
  end
end

# CLI usage
if __FILE__ == $PROGRAM_NAME
  require "optparse"

  options = { type: :movie, sort: :seeders, limit: 10 }
  available_languages = ProwlarrClient::LANGUAGE_KEYWORDS.keys.join(", ")

  parser = OptionParser.new do |opts|
    opts.banner = "Usage: #{$PROGRAM_NAME} [options] <title>"
    opts.separator ""
    opts.separator "Examples:"
    opts.separator "  #{$PROGRAM_NAME} \"Inception\" --year 2010"
    opts.separator "  #{$PROGRAM_NAME} \"Breaking Bad\" --tv --sort quality"
    opts.separator "  #{$PROGRAM_NAME} \"Spirited Away\" --year 2001 --language german"
    opts.separator ""

    opts.on("-y", "--year YEAR", Integer, "Filter by year (required for accuracy)") { |v| options[:year] = v }
    opts.on("--tv", "Search for TV shows instead of movies") { options[:type] = :tv }
    opts.on("-s", "--sort TYPE", %i[seeders quality relevance size], "Sort: seeders, quality, relevance, size") { |v| options[:sort] = v }
    opts.on("-l", "--limit N", Integer, "Number of results (default: 10)") { |v| options[:limit] = v }
    opts.on("--language LANG", "Search for dubs in language (#{available_languages})") { |v| options[:language] = v }
    opts.on("-h", "--help", "Show this help") { puts opts; exit }
  end

  parser.parse!
  options[:query] = ARGV[0]

  unless options[:query]
    puts parser
    exit 1
  end

  client = ProwlarrClient.new

  search_desc = "#{options[:query]}#{options[:year] ? " (#{options[:year]})" : ""}"
  search_desc += " [#{options[:language]} dub]" if options[:language]
  puts "Searching for: #{search_desc} [#{options[:type]}, sort: #{options[:sort]}]"
  puts ""

  results = client.magnet_links(
    options[:query],
    year: options[:year],
    type: options[:type],
    limit: options[:limit],
    sort_by: options[:sort],
    language: options[:language]
  )

  if results.empty?
    puts "No results found."
    exit 0
  end

  results.each_with_index do |r, i|
    puts "#{i + 1}. #{r[:title]}"
    puts "   Size: #{r[:size]} | Seeders: #{r[:seeders]} | Quality: #{r[:quality]} | #{r[:indexer]}"
    puts "   Magnet: #{r[:magnet][0, 80]}..." if r[:magnet]
    puts ""
  end
end
