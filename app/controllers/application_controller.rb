class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def current_label_ids
    session[:label_ids] ||= []
  end
  helper_method :current_label_ids

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
end
