Rails.application.routes.draw do
  # resource :session, controller: "clearance/sessions", only: [:create]
  # get "/sign_in" => "clearance/sessions#new", as: "sign_in"
  # delete "/sign_out" => "clearance/sessions#destroy", as: "sign_out"
  post '/sign_in' => 'sessions#sign_in'
  post '/sign_out' => 'sessions#sign_out'

  resources :lists do
    resources :items, only: [:index]
    resources :scraper_results, only: [:index] do
      collection do
        post :import
      end
    end
  end

  resources :items do
    put :scrape, on: :member
    put :restore, on: :member
    put :toggle_status, on: :member
    put :update_rating, on: :member
    delete :really_destroy, on: :member

    collection do
      get :archived
    end
  end

  # resources :tags

  # resource :profiles, only: [:update]
  # get '/profile' => 'profiles#show'
end
