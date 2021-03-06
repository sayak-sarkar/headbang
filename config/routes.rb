Rails.application.routes.draw do
  defaults format: :json do
    resources :collections, except: :edit do
      resources :tracks, only: :index
      resources :releases, only: :index
    end

    resources :releases, only: [:index, :show, :update] do
      resources :tracks, only: :index
      resources :releases, only: :index
      resource :artwork, only: :show
      post :lookup, on: :collection
    end

    resources :tracks, only: :show

    resources :artists, only: [:index, :show, :update] do
      resources :releases, only: :index
      resources :tracks, only: :index
    end

    resources :labels, only: [:index, :show, :update] do
      resources :artists, only: :index
      resources :releases, only: :index
    end

    resources :genres, only: [:index, :show, :update] do
      resources :artists, only: :index
      resources :releases, only: :index
    end

    resources :sources do
      post :scan, on: :collection
    end

    get "/browse", to: "browse#index"
  end
end
