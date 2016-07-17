Rails.application.routes.draw do
  root to: 'pages#index'
  devise_for :users, controllers: { registrations: "registrations" }
  
  resources :users

  resources :epicenters do
    resources :subscriptions do
      get "/cancel_change" => "subscriptions#cancel_change"
    end

    resources :memberships
    resources :fruittypes
    resources :access_points
    
    namespace :members do

    end
    get '/members' => 'epicenters#members'
    get '/tshirts' => 'epicenters#tshirts'
    post '/give_tshirt' => 'epicenters#give_tshirt'
  end

  get '/join_epicenter' => 'epicenters#join_epicenter'
  get '/leave_epicenter' => 'epicenters#leave_epicenter'
end
