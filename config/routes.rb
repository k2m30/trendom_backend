Rails.application.routes.draw do

  resources :profiles, only: [] do
    collection do
      post 'get_emails_available'
    end
  end

  devise_for :users, controllers: {omniauth_callbacks: 'users/oauth_callback'}

  resources :users, only: [:show] do
    member do
      get 'download'
    end
    collection do
      post 'add_profiles'
      post 'remove_profile'
    end
  end
  namespace :users do
    get 'oauth_callback_controller/google_oauth2'
  end

  # post 'download', to: 'users#download'
  get 'test/add_profiles', to: 'tests#add_profiles'
  get 'test/get_emails_available', to: 'tests#get_emails_available'

  post '/people/find', to: 'profiles#get_emails_available'

  post 'purchase', to: 'purchases#index'
  # get 'purchase', to: 'purchases#index'

  root 'users#show'
  mount Tail::Engine, at: '/tail'
end
