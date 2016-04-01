Rails.application.routes.draw do

  resources :profiles, only: [] do
    collection do
      post 'get_emails_available'
    end
  end

  devise_for :users, controllers: {omniauth_callbacks: 'users/oauth_callback'}

  resources :users, only: [:show] do
    member do
      # get 'show'
      post 'add_profiles'
      get 'download'
    end
  end
  namespace :users do
    get 'oauth_callback_controller/google_oauth2'
  end

  # post 'download', to: 'users#download'
  get 'test', to: 'tests#index'
  post 'test', to: 'tests#index'

  post '/people/find', to: 'profiles#get_emails_available'

  root 'users#show'
  mount Tail::Engine, at: '/tail'
end
