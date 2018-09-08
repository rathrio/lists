# frozen_string_literal: true

class ScraperResultsController < ApplicationController
  def index
    query = params[:query]
    scraper = current_list.default_scraper
    results = scraper.new(query: query).scrape
    results = FuzzySubstringMatchFilter.new(results, query).matches
    render json: results.to_json
  end

  def import
    item = Item.new(user: current_user)
    item.update_from(result_params.merge(list: current_list))
    render json: item.to_json
  end

  private

  def result_params
    params.require(:scraper_results).permit(
      :name,
      :description,
      :remote_image_url,
      :date,
      :links,
      :scraped,
      tags: []
    )
  end
end
