class ScraperResultsController < ApplicationController
  def index
    query = params[:query]
    scraper = Label.find(current_label_ids).map(&:default_scraper).compact.first
    results = scraper.new(query: query).scrape.map { |r| OpenStruct.new(r) }
    render partial: 'scraper_results', locals: { results: results }
  end
end
