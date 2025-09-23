Rails.application.routes.draw do
  mount MissionControl::Jobs::Engine, at: "/jobs"

  post "/sign_in" => "sessions#sign_in"
  post "/sign_out" => "sessions#sign_out"

  namespace :mobile do
    post "/sign_in" => "sessions#sign_in"
    post "/sign_out" => "sessions#sign_out"
  end
  get "/items/archived" => "items#archived"

  resources :lists, only: [:index] do
    resources :items, only: [:index, :update, :destroy], shallow: true do
      post :refresh_metadata, on: :member
      get :metadata, on: :member
      put :scrape, on: :member
      put :restore, on: :member
      put :toggle_status, on: :member
      delete :really_destroy, on: :member
    end

    resources :scraper_results, only: [:index] do
      collection do
        post :import
      end
    end
  end

  resource :profiles, only: [:update]
end
