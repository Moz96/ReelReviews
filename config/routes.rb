Rails.application.routes.draw do
  get 'maps/show'
  devise_for :users
  root to: 'places#index'

  resources :posts, only: [:index, :create, :new, :show]

  resources :places, only: [:index, :create, :show] do
    resources :posts, only: [:index, :show] do
      resources :comments, only: [:new, :create]
      collection do
        get 'next_batch'
      end
    end
  end

  resources :favourites, only: [:index, :create, :destroy]


  get 'map', action: :map, controller: 'places'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
