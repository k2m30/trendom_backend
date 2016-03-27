Rails.application.routes.draw do

  resources :people, as: :people, only: [:index] do
    collection do
      post 'find'
      post 'download'
      get 'search'
      get 'count'
    end
  end

  root 'persons#search'
  mount Tail::Engine, at: '/tail'
end
