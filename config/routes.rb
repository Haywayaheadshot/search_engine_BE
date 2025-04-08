Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :search, only: [:create]
      resources :analytics, only: [:index]
    end
  end
end
