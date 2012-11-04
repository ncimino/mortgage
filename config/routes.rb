Mortgage::Application.routes.draw do

  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users, :controllers => {:registrations => 'registrations'}

  get 'sessions/new'
  get "registrations/new"
  get "registrations/edit"
  #resources :authentications
  get "authentications/index"
  get "authentications/create"
  get "authentications/destroy"

  match '/auth/failure' => 'authentications#failure'
  match '/auth/:provider/callback' => 'authentications#create'

  resources :pages, :only => :show
  resources :loans

  root :to => 'loans#new', :id => 0

end
