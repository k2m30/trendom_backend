Rails.application.routes.draw do

  resources :profiles do
    collection do
      post 'find'
      post 'download'
      get 'search'
      get 'count'
    end
  end

  get 'welcome/index'

  namespace :users do
    get 'oauth_callback_controller/google_oauth2'
  end

  devise_for :users, :controllers => {:omniauth_callbacks => 'users/oauth_callback'}

  root 'welcome#index'
  mount Tail::Engine, at: '/tail'
end
