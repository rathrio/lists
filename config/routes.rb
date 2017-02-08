Rails.application.routes.draw do
  resources :labels

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :items do
    put :scrape, on: :member
  end

  root 'items#index'
end
