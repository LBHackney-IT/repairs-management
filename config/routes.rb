Rails.application.routes.draw do
  resources :stuffs

  root 'stuffs#index'
end
