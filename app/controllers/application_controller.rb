class ApplicationController < ActionController::Base
  include Clearance::Controller
  before_action :require_login

  protect_from_forgery with: :exception

  def current_label_ids
    session[:label_ids] ||= []
  end
  helper_method :current_label_ids

  def current_label
    return unless current_label_ids.count == 1
    current_user.labels.find_by(id: current_label_ids.first)
  end
  helper_method :current_label

  def current_label_id_params
    current_label_ids.join(',')
  end
  helper_method :current_label_id_params

  def set_label_ids(ids)
    session[:label_ids] = ids.split(',').map(&:to_i)
  end
  helper_method :set_label_ids

  def reset_label_ids
    session[:label_ids] = nil
  end
  helper_method :reset_label_ids

  def display_archived?
    params[:archived].present?
  end
  helper_method :display_archived?

  def focus_search?
    params[:focus_search].present?
  end
  helper_method :focus_search?
end
