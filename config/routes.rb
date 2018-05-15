Rails.application.routes.draw do
  get 'hello_world', to: 'hello_world#index'
  resource :session, controller: "clearance/sessions", only: [:create]
  get "/sign_in" => "clearance/sessions#new", as: "sign_in"
  delete "/sign_out" => "clearance/sessions#destroy", as: "sign_out"

  resources :lists
  resources :tags
  resources :scraper_results do
    collection do
      post :import
    end
  end

  resource :profiles, only: [:update]
  get '/profile' => 'profiles#show'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :items do
    put :scrape, on: :member
    put :restore, on: :member
    delete :really_destroy, on: :member
  end

  root 'items#root'
end
