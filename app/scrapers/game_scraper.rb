# frozen_string_literal: true

class GameScraper
  include Scraper

  def self.human_status_names
    @human_status_names ||= {
      todo: 'To Play',
      doing: 'Playing',
      done: 'Played'
    }
  end

  def search_results
    igdb_client.search(query)
  end

  def scrape_name(result)
    result['name']
  end

  def scrape_description(result)
    result['summary']
  end

  def scrape_image(result)
    url = result.dig('cover', 'url')

    if url.present?
      url = url.sub("t_thumb", "t_cover_big")
      url = url.sub("//", "https://") if url.start_with?('//')
    end

    url
  end

  def scrape_date(result)
    release_date_unix = result['first_release_date'].to_s
    return nil unless release_date_unix.present?

    # Parse UNIX time stamp.
    DateTime.strptime(release_date_unix, '%s')
  end

  def scrape_tags(result)
    return [] if result['genres'].blank?

    result['genres'].map { |g| g['name'] }.uniq.compact
  end

  private

  def igdb_client
    @igdb_client ||= IgdbClient.new
  end
end
