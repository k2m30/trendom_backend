Rails.application.routes.draw do

  resources :profiles, path: :people do
    collection do
      post 'find'
    end
  end

  devise_for :users, controllers: {omniauth_callbacks: 'users/oauth_callback'}

  resources :users do
    member do
      # get 'show'
      post 'add'
      get 'download'
    end
  end
  namespace :users do
    get 'oauth_callback_controller/google_oauth2'
  end

  # post 'download', to: 'users#download'



  root 'users#show'
  mount Tail::Engine, at: '/tail'
end
