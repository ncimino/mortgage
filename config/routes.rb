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

  get 'schedule/ideal'
  get 'schedule/actual'

  #get 'payments/new'
  #get 'payments/edit'
  #get 'payments/destroy'
  #get 'payments/ideal'
  get 'payments/actual'
  get 'payments/session_create'
  #match 'payments/session_create', :via => :put
  get 'session_payments/actual'

  get 'loans/summary'
  get 'loans/save_session'

  match '/auth/failure' => 'authentications#failure'
  match '/auth/:provider/callback' => 'authentications#create'

  resources :pages, :only => :show
  resources :session_payments #, :path => "/session/payments"
  resources :loans, :except => :edit do
    resources :payments, :except => :index, :shallow => true
  end

  root :to => 'loans#index'

end
