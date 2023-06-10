Rails.application.routes.draw do
  devise_for :users
  root to: 'posts#index'
  resources :posts do
    post 'videos', to: 'posts#create_video', on: :collection
  end
  resources :places, only: [:index, :create, :show] do
    resources :posts, only: [:new, :create] do
      collection do
        get 'next_batch'
      end
      resources :comments, only: [:index, :new, :create]
    end
  end
  resources :favourites, only: [:index]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
