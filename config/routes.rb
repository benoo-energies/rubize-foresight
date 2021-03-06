Rails.application.routes.draw do
  devise_for :users, :controllers => { :registrations => "registrations"}
  root to: 'pages#home'

  namespace :admin do
    resources :users, only: [:index, :update]
  end

  resources :uses, only: [:new, :create, :edit, :update, :destroy]
  resources :appliances, only: [:index, :show, :new, :create, :edit, :update, :destroy], shallow: true do
    resources :sources, only: [:new, :create, :edit, :update, :destroy]
    member do
      post 'duplicate'
    end
  end

  resources :projects, only: [:index, :show, :new, :create, :edit, :update, :destroy], shallow: true do
    resources :project_appliances, only: [:new, :create, :edit, :update, :destroy]
    resources :solar_systems, only: [:new, :create, :edit, :update, :destroy]
    member do
      get 'appliances'
      post 'duplicate'
    end
  end

  get 'projects/public/:token', to: 'projects#public', as: 'public_project'
  post 'projects/public/:token/load', to: 'projects#load', as: 'project_load'

  get 'appliance_refresh_load', to: 'appliances#refresh_load'
  get 'project_appliance_refresh_load', to: 'project_appliances#refresh_load'

  get 'power_components', to: 'pages#power_components'
  resources :power_systems, only: [:new, :create, :edit, :update, :destroy]
  resources :batteries, only: [:new, :create, :edit, :update, :destroy]
  resources :solar_panels, only: [:new, :create, :edit, :update, :destroy]
  resources :communication_modules, only: [:new, :create, :edit, :update]
  resources :distributions, only: [:new, :create, :edit, :update]

  post 'request_registration', to: 'pages#request_registration'
end
