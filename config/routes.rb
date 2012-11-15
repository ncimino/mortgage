Mortgage::Application.routes.draw do

  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users, :controllers => {:registrations => 'registrations'}

  get 'sessions/new'
  get 'registrations/new'
  get 'registrations/edit'
  get 'authentications/index'
  get 'authentications/create'
  get 'authentications/destroy'

  match '/loans/summary', :via => :get
  match '/loans/schedule', :via => :get
  match '/loans/payments', :via => :get
  match '/auth/failure' => 'authentications#failure'
  match '/auth/:provider/callback' => 'authentications#create'


  resources :pages, :only => :show
  resources :loans do
    resources :payments
    #, :shallow => true
  end

  root :to => 'loans#new', :id => 0

end
