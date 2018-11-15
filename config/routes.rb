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

  if ENV['DELAYED_JOB_WEB_USER'] && ENV['DELAYED_JOB_WEB_PASSWORD']
    match "/delayed_job" => DelayedJobWeb, :anchor => false, :via => [:get, :post]
  end

  namespace :api do
    resources :properties, only: [], param: :ref do
      member do
        get :repairs_history
      end
    end

    resources :work_orders, only: [], param: :ref do
      member do
        get :description
        get :documents
        get :notes_and_appointments
        get :possibly_related_work_orders
        get :related_work_orders
      end
    end
  end
end
