Rails.application.routes.draw do
  resources :labels

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :items do
    put :scrape, on: :member
    put :scrape, on: :collection, to: 'items#scrape_all'
  end

  root 'items#index'
end
