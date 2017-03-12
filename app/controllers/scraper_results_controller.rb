class ScraperResultsController < ApplicationController
  def index
    query = params[:query]
    scraper = current_user.labels.find(current_label_ids).map(&:default_scraper).compact.first
    results = scraper.new(query: query).scrape

    relevant_results = results.select { |result| result[:is_reliable] }
    matching_results = FuzzySubstringMatchFilter.new(results, query).matches
    
    # intersection of relevant and matching results
    results = relevant_results & matching_results
    results = relevant_results if results.empty?

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
      :is_reliable,
      tags: []
    )
  end
end
