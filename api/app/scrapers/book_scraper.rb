# frozen_string_literal: true

class BookScraper
  include Scraper

  def self.human_status_names
    @human_status_names ||= {
      todo: "To Read",
      doing: "Reading",
      done: "Read",
    }
  end

  def search_results
    title = query.strip.tr(" ", "+")
    google_books_client.search(title, filter_values:)["items"]
  end

  def scrape_name(result)
    result["volumeInfo"]["title"]
  end

  def scrape_description(result)
    result["volumeInfo"]["description"]
  end

  def scrape_image(result)
    result.dig("volumeInfo", "imageLinks", "thumbnail")
  end

  def scrape_date(result)
    published_date = result["volumeInfo"]["publishedDate"]
    return unless published_date.present?

    if published_date.split("-").count == 1
      DateTime.strptime(published_date, "%Y")
    else
      DateTime.strptime(published_date, "%Y-%m")
    end
  end

  def scrape_tags(result)
    categories = result["volumeInfo"]["categories"]
    return categories if categories.present?

    []
  end

  def scrape_links(result)
    [
      Link.new(url: result["volumeInfo"]["canonicalVolumeLink"]),
    ]
  end

  def scrape_language(result)
    result["volumeInfo"]["language"]
  end

  private

  def google_books_client
    @google_books_client ||= GoogleBooksClient.new
  end
end
