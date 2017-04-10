Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'service_providers#index'
  resources :service_providers, only: [:create, :show, :update] do
    resources :consumers, only: [:index, :create, :update]
  end
  match '/:service_provider_id/oauth2/token', to: 'oauth2#token', as: 'oauth2_token', via: [:get, :post]
  get '/:service_provider_id/oauth2/authorize', to: 'oauth2#authorize', as: 'oauth2_authorize'
  post '/:service_provider_id/oauth2/authorize', to: 'oauth2#authorize_redirect_with_code', as: 'oauth2_authorize_redirect_with_code'
  get '/auth/:provider/callback', to: 'sessions#create', as: 'auth_callback'
  post '/logout', to: 'sessions#destroy'
end
