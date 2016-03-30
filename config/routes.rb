Rails.application.routes.draw do

  get 'welcome/index'

  namespace :users do
  get 'oauth_callback_controller/google_oauth2'
  end

  devise_for :users, :controllers => { :omniauth_callbacks => 'users/oauth_callback'}

  resources :people, as: :people, only: [:index] do
    collection do
      post 'find'
      post 'download'
      get 'search'
      get 'count'
    end
  end



  root 'welcome#index'
  mount Tail::Engine, at: '/tail'
end
