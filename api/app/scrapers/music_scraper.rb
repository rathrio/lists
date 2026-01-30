class MusicScraper
  include Scraper

  def self.human_status_names
    @human_status_names ||= {
      todo: "To Listen",
      doing: "Listening",
      done: "Listened",
    }
  end

  def search_results
    musicbrainz_client.search(query, filter_values: filter_values)
  end

  def scrape_name(result)
    artist = primary_artist(result)
    title = result["title"]

    if artist.present?
      "#{artist} - #{title}"
    else
      title
    end
  end

  def scrape_description(result)
    result["disambiguation"]
  end

  def scrape_image(result)
    mbid = result["id"]
    musicbrainz_client.cover_art_url(mbid) if mbid.present?
  end

  def scrape_date(result)
    date_str = result["date"]
    return nil if date_str.blank?

    case date_str
    when /^\d{4}$/
      Date.new(date_str.to_i)
    when /^\d{4}-\d{2}$/
      Date.strptime(date_str, "%Y-%m")
    else
      Date.parse(date_str)
    end
  rescue ArgumentError
    nil
  end

  def scrape_links(result)
    mbid = result["id"]
    return [] if mbid.blank?

    [
      Link.new(url: "https://musicbrainz.org/release/#{mbid}")
    ]
  end

  def scrape_metadata(result)
    {
      mbid: result["id"],
      artist: primary_artist(result),
      label: primary_label(result),
      country: result["country"],
      barcode: result["barcode"],
      status: result["status"],
    }.compact
  end

  private

  def primary_artist(result)
    result.dig("artist-credit", 0, "name") ||
      result.dig("artist-credit", 0, "artist", "name")
  end

  def primary_label(result)
    result.dig("label-info", 0, "label", "name")
  end

  def musicbrainz_client
    @musicbrainz_client ||= MusicbrainzClient.new
  end
end
