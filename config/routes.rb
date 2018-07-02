Rails.application.routes.draw do
  resources :stuffs

  root 'stuffs#index'

  post '/auth/:provider/callback', to: 'sessions#create'
end
