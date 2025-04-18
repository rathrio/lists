# frozen_string_literal: true

class TvScraper
  include Scraper

  def self.human_status_names
    MovieScraper.human_status_names
  end

  def search_results
    moviedb_client.search(query, type: :tv, filter_values:)["results"].to_a
  end

  def scrape_name(result)
    result["name"]
  end

  def scrape_original_name(result)
    result["original_name"]
  end

  def scrape_description(result)
    result["overview"]
  end

  def scrape_image(result)
    MoviedbClient::POSTER_BASE_URI + result["poster_path"] if result["poster_path"]
  end

  def scrape_date(result)
    Date.parse(result["first_air_date"]) if result["first_air_date"].present?
  end

  def scrape_tags(result)
    result["genre_ids"].map { |id| MoviedbClient::GENRES[id] }.compact
  end

  def scrape_language(result)
    result["original_language"]
  end

  def scrape_metadata(result)
    tmdb_id = result["id"]
    return if tmdb_id.blank?

    { tmdb_id: }.merge(moviedb_client.tv_show_season_metadata(tmdb_id))
  end

  private

  def moviedb_client
    @moviedb_client ||= MoviedbClient.new
  end
end
