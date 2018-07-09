Rails.application.routes.draw do
  resources :stuffs

  root 'stuffs#index'

  get '/login', to: 'sessions#new'
  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  get '/logout', to: 'sessions#destroy'
end
