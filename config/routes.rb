Console1984::Engine.routes.draw do
  resources :sessions, only: %i[ index show ]

  root to: "sessions#index"
end
