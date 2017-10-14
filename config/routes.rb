Rails.application.routes.draw do
  root to: 'pages#index'
  devise_for :users, controllers: { registrations: "registrations" }
  
  resources :users do
    get '/memberships' => 'users#memberships'
    get '/fruitbasket' => 'users#fruitbasket'
    get '/caretaker' => 'users#caretaker'
    post '/support_epicenter' => 'users#support_epicenter'
  end

  resources :epicenters do
    resources :subscriptions do
      get "/cancel_change" => "subscriptions#cancel_change"
    end

    resources :epipages
    resources :memberships
    resources :fruittypes
    resources :access_points
    resources :information
    resources :resources
    
    namespace :members do
    end

    resources :epicenters

    get '/edit_engagement' => 'epicenters#edit_engagement'
    get '/edit_members' => 'epicenters#edit_members'
    get '/edit_meeting_time' => 'epicenters#edit_meeting_time'
    get '/confirm_plant' => 'epicenters#confirm_plant'

    get '/members' => 'epicenters#members'
    get '/tshirts' => 'epicenters#tshirts'
    post '/give_tshirt' => 'epicenters#give_tshirt'
  end

  get '/info' => 'pages#info'
  get '/join_epicenter' => 'epicenters#join_epicenter'
  get '/leave_epicenter' => 'epicenters#leave_epicenter'
end
