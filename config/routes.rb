Rails.application.routes.draw do
  root to: 'application#index'

  resources :short_urls, only: [:create, :show], constraints: { format: 'json' } do
    collection do
      get :top
    end
  end
end
