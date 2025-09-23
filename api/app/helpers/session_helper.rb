module SessionHelper
  def current_list_ids
    session[:list_ids] ||= []
  end

  def current_list
    current_user.lists.find(params[:list_id])
  end

  def current_list_id
    if current_list.nil?
      raise "Cannot retrieve list id"
    end

    current_list.id
  end

  def current_list_id_params
    current_list_ids.join(',')
  end

  def set_list_ids(ids)
    session[:list_ids] = ids.to_s.split(',').map(&:to_i)
  end

  def reset_list_ids
    session[:list_ids] = nil
  end

  def display_archived?
    params[:archived].present?
  end

  def focus_search?
    params[:focus_search].present?
  end

  # SessionsController#validate_token does the validation. Here we can assume everything is A-OK.
  def current_user
    User.find(1)
    # token = cookies.signed[:jwt]
    # data = JwtService.decode(token)
    # User.find(data.first['user_id'])
  end
end
