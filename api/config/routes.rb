require "sidekiq/web" # require the web UI

# Configure Sidekiq-specific session middleware
Sidekiq::Web.use ActionDispatch::Cookies
Sidekiq::Web.use ActionDispatch::Session::CookieStore, key: "_interslice_session"

Rails.application.routes.draw do
  mount Sidekiq::Web => "/sidekiq" # access it at http://localhost:3000/sidekiq

  post "/sign_in" => "sessions#sign_in"
  post "/sign_out" => "sessions#sign_out"
  get "/items/archived" => "items#archived"

  resources :lists, only: [:index] do
    resources :items, only: [:index, :update, :destroy], shallow: true do
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
