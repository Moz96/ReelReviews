Rails.application.routes.draw do
  devise_for :users
  root to: 'posts#index'
  resources :posts
  resources :places, only: [:index, :new, :create, :show] do
    resources :posts do
      resources :comments, only: [:index, :new, :create]
    end
  end
  resources :favourites, only: [:index]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
