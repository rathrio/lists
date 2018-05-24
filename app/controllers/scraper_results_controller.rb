class ScraperResultsController < ApplicationController
  def index
    query = params[:query]
    scraper = current_list.default_scraper
    results = scraper.new(query: query).scrape
    results = FuzzySubstringMatchFilter.new(results, query).matches
    render json: results.to_json

    # results = results.map { |r| OpenStruct.new(r) }
    # render partial: 'scraper_results', locals: { results: results }, layout: false
  end

  def import
    item = Item.new(user: current_user)
    item.update_from(result_params.merge(list: current_list))
    flash[:notice] = 'Item successfully added'
    redirect_to items_path(list_ids: current_list_id_params)
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
