Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  resources :users, only: [:show, :create, :update, :destroy] # Add authentication later

  resources :stores, only: [:index, :show]
  resources :products, only: [:index, :show]

  resources :deals, only: [:index, :show]

  resources :favourites, only: [:index, :create, :destroy]
  resources :shopping_lists, only: [:index, :create, :destroy]
end
