module SessionHelper
  JWT_ALGORITHM = 'HS256'

  def jwt_secret
    Rails.application.secrets.secret_key_base
  end

  def jwt_encode(user)
    JWT.encode({ user_id: user.id }, jwt_secret, JWT_ALGORITHM)
  end

  def jwt_decode(token)
    JWT.decode(token, jwt_secret, true, algorithm: JWT_ALGORITHM)
  end

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
    token = cookies.signed[:jwt]
    data = jwt_decode(token)
    User.find(data.first['user_id'])
  end
end
