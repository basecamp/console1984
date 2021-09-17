Rails.application.routes.draw do
  mount Console1984::Engine => "/console1984"

  resources :remote_people
end
