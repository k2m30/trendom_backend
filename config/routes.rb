Rails.application.routes.draw do

  resources :profiles, path: :people do
    collection do
      post 'find'
      get 'search'
      get 'count'
    end
  end

  get 'welcome/index'

  resource :users do
    member do
      get 'show'
    end
  end
  namespace :users do
    get 'oauth_callback_controller/google_oauth2'
  end

  post 'download', to: 'users#download'

  devise_for :users, controllers: {omniauth_callbacks: 'users/oauth_callback'}

  root 'users#show'
  mount Tail::Engine, at: '/tail'
end
