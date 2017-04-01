Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'service_providers#index'
  resources :service_providers, only: [:new, :create, :show] do
    resources :consumers, only: [:index, :create]
  end
  post '/oauth2/token', to: 'oauth2#token', as: 'oauth2_token'
end
