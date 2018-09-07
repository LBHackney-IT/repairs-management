Rails.application.routes.draw do
  get '/login', to: 'sessions#new'
  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  get '/logout', to: 'sessions#destroy'

  resources :work_orders, only: [:show], param: :ref do
    post :search, on: :collection
  end

  root to: 'pages#home'

  if Rails.env.development?
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end
end
