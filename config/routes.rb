Rails.application.routes.draw do
  resource :session, controller: "clearance/sessions", only: [:create]
  get "/sign_in" => "clearance/sessions#new", as: "sign_in"
  delete "/sign_out" => "clearance/sessions#destroy", as: "sign_out"

  resources :labels
  resources :tags
  resources :scraper_results

  resource :profiles, only: [:update]
  get '/profile' => 'profiles#show'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :items do
    put :scrape, on: :member
    put :restore, on: :member
    delete :really_destroy, on: :member
  end

  root 'items#index'
end
