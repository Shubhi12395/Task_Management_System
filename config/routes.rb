Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  namespace :api do
    namespace :v1 do
      post 'auth/signup', to: 'users#create'
      post 'auth/login', to: 'users#login'
      delete 'auth/logout', to: 'users#logout' 
      get  'users/me',  to:  'profile#show'
      patch 'users/me',   to:  'profile#update'
      post 'users/me/avatar', to: 'profile#avatar'
      post 'tasks' ,    to:  'tasks#create'
      get 'tasks',   to: 'tasks#index'
      get 'tasks/:id', to: 'tasks#show'
      patch 'tasks/:id', to: 'tasks#update'
      delete 'tasks/:id', to: 'tasks#destroy'
    end 
  end
end
