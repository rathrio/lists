class ScraperResultsController < ApplicationController
  def index
    query = params[:query]
    scraper = current_user.labels.find(current_label_ids).map(&:default_scraper).compact.first
    results = scraper.new(query: query).scrape
    results = FuzzySubstringMatchFilter.new(results, query).matches
    results = results.map { |r| OpenStruct.new(r) }
    render partial: 'scraper_results', locals: { results: results }
  end
end
