Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'service_providers#index'
  resources :service_providers, only: [:create, :show, :update] do
    resources :consumers, only: [:index, :create, :update]
  end
  post '/:service_provider_id/oauth2/token', to: 'oauth2#token', as: 'oauth2_token'
  get '/:service_provider_id/oauth2/authorize', to: 'oauth2#authorize', as: 'oauth2_authorize'
  get '/auth/:provider/callback', to: 'sessions#create', as: 'auth_callback'
  post '/logout', to: 'sessions#destroy'
end
