Rails.application.routes.draw do

  resources :persons, as: :trendom, only: [:index] do
    collection do
      get 'find'
      get 'search'
      get 'count'
    end
  end

  root 'persons#search'
  mount Tail::Engine, at: '/tail'
end
