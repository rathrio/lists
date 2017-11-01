if Rails.env.development?
  GraphiQL::Rails.config.headers['Authorization'] = -> (context) do
    "Token #{context.request.env[:clearance].current_user.try(:api_token)}"
  end
end
