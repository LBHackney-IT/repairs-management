Rails.application.routes.draw do
  resources :stuffs

  root 'stuffs#index'

  delete '/logout', to: 'sessions#destroy'
  post '/auth/:provider/callback', to: 'sessions#create'
end
