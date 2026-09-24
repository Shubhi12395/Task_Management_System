Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  namespace :api do
    namespace :v1 do
      get "auth/signup", to: "users#new"
      post "auth/signup", to: "users#create"
      get "auth/login", to: "sessions#new"
      post "auth/login", to: "sessions#login"
      delete "auth/logout", to: "sessions#logout", as: :logout
      patch "auth/password_reset", to: "users#password_reset"
      post "auth/forgot_password", to: "users#forgot_password"
      patch "auth/forgot_password/reset", to: "users#forgot_pwd_reset"
      
      get "users/me",  to:  "profile#show"
      get "users/me/edit",  to:  "profile#edit"
      patch "users/me",   to:  "profile#update"
      post "users/me/avatar", to: "profile#avatar"
      
      post "users/comments", to: "comment#create"
      get "users/comments", to: "comment#index"
      delete "users/comments/:id", to: "comment#destroy"
      
      post "tasks",    to:  "tasks#create"
      get "tasks",   to: "tasks#index"
      get "tasks/duetoday",   to: "tasks#duetoday"
      get "tasks/overdue",   to: "tasks#overdue"
      get "tasks/pending",   to: "tasks#pending"
      get "tasks/by_priority",   to: "tasks#by_priority"
      
      get "tasks/sortby/:sort",   to: "tasks#sort"
      get "tasks/searchby/:search", to: "tasks#search"
      get "tasks/:id", to: "tasks#show"
      get "tasks/:id/edit", to: "tasks#edit"
      patch "tasks/:id", to: "tasks#update", as: :api_v1_task
      patch "tasks", to: "tasks#update_all"
      delete "tasks/:id", to: "tasks#destroy"
      delete "tasks", to: "tasks#destroy_all"
      
      post "projects",    to:  "projects#create"
      get "projects",   to: "projects#index"
      get "projects/:id", to: "projects#show"
      get "projects/:id/edit", to: "projects#edit"
      patch "projects/:id", to: "projects#update"
      delete "projects/:id", to: "projects#destroy"
      
      post "tasks/:task_id/comments", to: "comment#create"
      get "tasks/:task_id/comments", to: "comment#index"
      delete "tasks/:task_id/comments/:id", to: "comment#destroy"
    end
  end
end
