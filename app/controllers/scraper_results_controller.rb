# frozen_string_literal: true

class ScraperResultsController < ApplicationController
  def index
    query = params[:query]
    filter_values = params[:filter_values]
    filter_values = if filter_values.present? 
                      filter_values.map { |v| Oj.load(v) } 
                    else
                      []
                    end

    scraper = current_list.default_scraper
    results = scraper.new(query: query, filter_values: filter_values).scrape

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
      :original_name,
      :description,
      :remote_image_url,
      :date,
      :links,
      :scraped,
      :language,
      tags: []
    )
  end
end
