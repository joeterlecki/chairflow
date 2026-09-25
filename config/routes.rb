Rails.application.routes.draw do
  root "calendar#index"
  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout
  get "team_schedule", to: "stylists#index", as: :team_schedule
  resources :stylists, only: %i[index edit update] do
    resource :shift, controller: "scheduled_shifts", only: %i[edit update destroy]
  end
  resources :time_offs, only: %i[new create destroy]
  resources :services, only: %i[index edit update]
  resources :clients, only: %i[index new create edit update]
  resources :appointments, except: :index do
    get :availability, on: :collection
  end
  get "up" => "rails/health#show", as: :rails_health_check
end
