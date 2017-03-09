class ScraperResultsController < ApplicationController
  def index
    query = params[:query]
    scraper = current_user.labels.find(current_label_ids).map(&:default_scraper).compact.first
    results = scraper.new(query: query).scrape
    results = FuzzySubstringMatchFilter.new(results, query).matches
    results = results.map { |r| OpenStruct.new(r) }
    render partial: 'scraper_results', locals: { results: results }, layout: false
  end

  def import
    item = Item.new(user: current_user)
    item.update_from(result_params.merge(labels: [current_label]))
    flash[:notice] = 'Item successfully added'
    redirect_to items_path(label_ids: current_label_id_params)
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
