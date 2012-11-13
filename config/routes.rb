Mortgage::Application.routes.draw do

  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users, :controllers => {:registrations => 'registrations'}

  resources :pages, :only => :show
  resources :loans do
    resource :payments
  end

  get 'sessions/new'
  get 'registrations/new'
  get 'registrations/edit'
  get 'authentications/index'
  get 'authentications/create'
  get 'authentications/destroy'

  match 'loans/summary', :via => :get
  match 'loans/schedule', :via => :get
  #match 'loans/payments', :via => :get
  match '/auth/failure' => 'authentications#failure'
  match '/auth/:provider/callback' => 'authentications#create'

  #match 'loans/:id/new_payment_form', :via => :get

  root :to => 'loans#new', :id => 0

end
