class RecipeScraper
  include Scraper

  def search_results
    edamam_client.search(query.strip)['hits']
  end

  def scrape_name(result)
    result['recipe']['list']
  end

  def scrape_description(result)
    result['recipe']['ingredientLines'].join("\n")
  end

  def scrape_image(result)
    result['recipe']['image']
  end

  def scrape_tags(result)
    result['recipe']['healthLists']
  end

  def scrape_links(result)
    [
      Link.new(url: result['recipe']['url'])
    ]
  end

  private

  def edamam_client
    @edamam_client ||= EdamamClient.new
  end
end
