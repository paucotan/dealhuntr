Rails.application.routes.draw do
  get 'shopping_lists/index'
  patch 'shopping_lists/update'
  delete 'shopping_lists/destroy'
  delete 'shopping_lists/reset'
  get 'favourites/index'
  get 'favourites/create'
  get 'favourites/destroy'
  get 'search', to: 'pages#search'

  devise_for :users
  root to: "pages#home"
  get 'dashboard', to: 'pages#dashboard' # dashboard route

  resources :stores, only: [:index, :show]
  resources :products, only: [:index]

  resources :deals, only: [:show] do
    get :related, on: :member
  end

  resources :favourites, only: [:index, :destroy]
  resources :shopping_lists, only: [:index, :create, :update, :destroy] do
    collection do
      delete :reset  # Route to clear the shopping list
    end
  end
end
