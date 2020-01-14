require 'sidekiq/web'

Rails.application.routes.draw do
  root to: 'application#index'

  resources :short_urls, only: [:create, :show], constraints: { format: 'json' } do
    collection do
      get :top
    end
  end

  mount Sidekiq::Web => '/sidekiq' if Rails.env.development?

  match '*path' => 'application#reroute', via: [:get]
end