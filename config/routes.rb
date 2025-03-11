Rails.application.routes.draw do
  get 'deals/index'
  get 'deals/show'
  devise_for :users
  root to: "pages#home"

  resources :stores, only: [:index, :show]
  resources :products, only: [:index]

  resources :deals, only: [:index, :show]

  resources :favourites, only: [:index, :destroy]
  resources :shopping_lists, only: [:index, :destroy]
end
