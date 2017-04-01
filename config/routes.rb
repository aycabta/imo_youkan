Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'service_providers#index'
  get '/service_providers/new', to: 'service_providers#new'
  post '/service_providers/create', to: 'service_providers#create'
  get '/service_providers/:id', to: 'service_providers#show', as: 'service_providers'
end
