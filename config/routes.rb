Rails.application.routes.draw do
  root to: 'pages#index'
  devise_for :users
  resources :users
  resources :epicenters do
    resources :memberships
    resources :fruittypes
  end

  get '/join_epicenter' => 'epicenters#join_epicenter'
  get '/leave_epicenter' => 'epicenters#leave_epicenter'
end
