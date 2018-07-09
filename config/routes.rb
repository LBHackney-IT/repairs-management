Rails.application.routes.draw do
  get '/login', to: 'sessions#new'
  match '/auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  get '/logout', to: 'sessions#destroy'

  root to: 'pages#home'
end
