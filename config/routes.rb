Console1984::Engine.routes.draw do
  resources :sessions, only: %i[ index show ]
  resource :filtered_sessions, only: %i[ update ]
  root to: "sessions#index"
end
