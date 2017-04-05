Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'service_providers#index'
  resources :service_providers, only: [:create, :show] do
    resources :consumers, only: [:index, :create]
  end
  post '/:service_provider_id/oauth2/token', to: 'oauth2#token', as: 'oauth2_token'
  get '/auth/:provider/callback', to: 'sessions#create', as: 'auth_callback'
  post '/logout', to: 'sessions#destroy'
end
