Rails.application.routes.draw do
  resources :stuffs

  root 'stuffs#index'

  post '/auth/:provider/callback', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy'
end
