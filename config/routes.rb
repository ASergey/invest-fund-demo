Rails.application.routes.draw do

  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.has_any_role?(RoleName::ADMIN, RoleName::ADMIN_READ_ONLY) } do
    mount Sidekiq::Web => '/sidekiq_monitor'
  end

  mount API::Root, at: '/'
  mount GrapeSwaggerRails::Engine, at: '/api/doc'

  root to: 'admin/dashboard#index'
  devise_for :users
  # devise_for :users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  namespace :admin do
    resources :users do
      resources :fund_operations
    end

    resources :instruments do
      resources :fund_operations
    end
  end  
end