Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "enterprise#dashboard"

  get "dashboard", to: "enterprise#dashboard"
  resources :companies, except: [:destroy] do
    member do
      get :configuration
    end
  end
  get "accounts", to: "enterprise#accounts"
  get "services", to: "enterprise#services"
  get "costs", to: "enterprise#costs"
  get "collections", to: "enterprise#collections"
  get "invoices", to: "enterprise#invoices"
  get "contracts", to: "enterprise#contracts"
  get "reports", to: "enterprise#reports"
  get "settings", to: "enterprise#settings"
end
