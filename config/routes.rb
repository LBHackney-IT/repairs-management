Rails.application.routes.draw do
  get '/login', to: 'sessions#new'
  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  post '/review_app_login', to: 'sessions#review_app_login'
  get '/logout', to: 'sessions#destroy'

  resources :work_orders, only: [:show], param: :ref do
    post :search, on: :collection
  end

  resources :properties, only: [:show], param: :ref do
    get :search, on: :collection
  end

  root to: 'pages#home'

  if Rails.env.development?
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end

  namespace :api do
    resources :properties, only: [], param: :ref do
      member do
        get :possibly_related_work_orders
      end
    end

    resources :work_orders, only: [], param: :ref do
      member do
        get :description
        get :notes_and_appointments
        get :documents
        get :repairs_history
      end
    end
  end
end
