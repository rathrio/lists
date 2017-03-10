class ApplicationController < ActionController::Base
  include Clearance::Controller
  before_action :require_login

  protect_from_forgery with: :exception

  def current_list_ids
    session[:list_ids] ||= []
  end
  helper_method :current_list_ids

  def current_list
    return unless current_list_ids.count == 1
    current_user.lists.find_by(id: current_list_ids.first)
  end
  helper_method :current_list

  def current_list_id_params
    current_list_ids.join(',')
  end
  helper_method :current_list_id_params

  def set_list_ids(ids)
    session[:list_ids] = ids.split(',').map(&:to_i)
  end
  helper_method :set_list_ids

  def reset_list_ids
    session[:list_ids] = nil
  end
  helper_method :reset_list_ids

  def display_archived?
    params[:archived].present?
  end
  helper_method :display_archived?

  def focus_search?
    params[:focus_search].present?
  end
  helper_method :focus_search?
end
