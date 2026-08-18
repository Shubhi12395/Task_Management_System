Rails.application.routes.draw do
   namespace :api do
    namespace :v1 do
         post 'auth/signup', to: 'users#create'
          post 'auth/login', to: 'users#login'
    end 
  end
end
