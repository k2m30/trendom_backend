require 'resque/server'

Rails.application.routes.draw do
  root to: 'users#index'

  resources :profiles, only: [:edit, :update] do
    collection do
      post 'get_emails_available'
    end
    member do
      patch 'set_primary_email'
    end
  end

  get 'home', to: 'users#index', as: 'user_root'

  devise_for :users, controllers: {omniauth_callbacks: 'users/oauth_callback'}

  resources :users, only: [:edit, :update, :index], path: :home do
    collection do
      post 'add_profiles'
      post 'remove_profile'
      get 'choose_plan'
      get 'download'
      get 'progress'
      get 'reveal_emails'
    end
  end

  namespace :users do
    get 'oauth_callback_controller/google_oauth2'
  end

  authenticate :user do
    mount Resque::Server, at: '/jobs'
    mount Tail::Engine, at: '/tail'
  end

  resources :email_templates, only: [:index, :update, :destroy, :new] do
    get 'clone'
    member do
    end
  end

  resources :campaigns do
    member do
      post 'send', to: 'campaigns#send_out'
    end
  end

  post '/people/find', to: 'profiles#get_emails_available'

  post 'purchase', to: 'purchases#index'
  # get 'purchase', to: 'purchases#index'
end
