Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "enterprise#dashboard"

  get "login", to: "sesiones#new"
  post "login", to: "sesiones#create"
  delete "logout", to: "sesiones#destroy"

  get "dashboard", to: "enterprise#dashboard"
  get "services", to: redirect("/productos_servicios")
  get "parametros", to: "enterprise#parametros"
  patch "parametros", to: "enterprise#actualizar_parametros"
  get "auditoria", to: "enterprise#auditoria"
  resources :cotizaciones, only: [:index, :update] do
    member do
      patch :actualizar_estado
    end
  end
  resources :clientes do
    member do
      get :expediente, to: "expediente_clientes#show"
      patch :expediente_documentos, to: "expediente_clientes#actualizar_documentos"
    end
  end
  resources :productos_servicios do
    member do
      match :cotizacion, via: %i[get post]
      get :cotizacion_pdf
      post :agregar_precio
      post :agregar_costo
    end
  end
  resources :monedas
  resources :companies, except: [:destroy] do
    member do
      get :configuration
    end
  end
  resources :usuarios do
    member do
      patch :permisos
    end
  end
  resources :roles do
    member do
      match :permisos, via: %i[get patch]
    end
  end
  resources :modulos_sistema
  get "accounts", to: "enterprise#accounts"
  get "costs", to: "enterprise#costs"
  get "collections", to: "enterprise#collections"
  get "invoices", to: "enterprise#invoices"
  get "contracts", to: "enterprise#contracts"
  get "reports", to: "enterprise#reports"
  get "settings", to: "enterprise#settings"
end
