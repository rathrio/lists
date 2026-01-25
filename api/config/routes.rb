Rails.application.routes.draw do
  mount MissionControl::Jobs::Engine, at: "/jobs"

  post "/sign_in" => "sessions#sign_in"
  post "/sign_out" => "sessions#sign_out"
  get "/items/archived" => "items#archived"
  get "/items/journal" => "items#journal"

  resources :lists, only: [:index] do
    resources :items, only: [:index, :show, :update, :destroy], shallow: true do
      post :refresh_metadata, on: :member
      post :refresh_torrents, on: :member
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
