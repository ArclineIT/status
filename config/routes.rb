Rails.application.routes.draw do
  root "status#show"

  get "status",   to: "status#show",    as: :status, defaults: { format: :json }, constraints: { format: :json }
  get "history",  to: "status#history", as: :history
  get "feed.xml", to: "status#feed",    as: :feed

  namespace :admin do
    root "dashboard#show"
    resources :components, only: %i[ create update destroy ]
    resources :incidents, only: %i[ new create show destroy ] do
      post :post_update, on: :member
    end
    resources :maintenances, only: %i[ new create destroy ]
  end

  # Health check for load balancers and uptime monitors.
  get "up" => "rails/health#show", as: :rails_health_check
end
