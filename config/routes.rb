Rails.application.routes.draw do
  # Authentication routes
  get "login", to: "sessions#new"
  delete "logout", to: "sessions#destroy"
  get "logout", to: "sessions#destroy"  # Allow GET for easier testing
  
  # OIDC routes
  get "/auth/:provider/callback", to: "sessions#omniauth_callback"
  get "/auth/failure", to: "sessions#omniauth_failure"
  
  # Test-only route for simulating login
  if Rails.env.test?
    post "/test_login", to: "sessions#test_login"
  end
  
  # Main application routes
  root "schedules#index"
  
  # Schedule management
  resources :schedules, only: [:index, :edit, :update]
  
  # Admin routes
  namespace :admin do
    resources :users
    resources :teams
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
