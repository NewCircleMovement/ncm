Rails.application.routes.draw do
  # get 'member_resources/index'

  # get 'member_resources/show'

  # get 'member_resources/new'

  # get 'member_resources/edit'

  # get 'member_resources/create'

  # get 'member_resources/destroy'

  # get 'giveaways/index'

  # get 'giveaways/new'

  root to: 'pages#index'
  devise_for :users, controllers: { registrations: "registrations" }
  
  resources :users do
    get '/admissions' => 'users#admissions'
    get '/memberships' => 'users#memberships'
    get '/fruitbasket' => 'users#fruitbasket'
    get '/caretaker' => 'users#caretaker'
    get '/payment' => 'users#payments'
    post '/support_epicenter' => 'users#support_epicenter'

    resources :member_resources
    
  end

  resources :epicenters do
    resources :subscriptions do
      # post "/update_creditcard" => "subscriptions#update_creditcard"
      get "/welcome" => "subscriptions#welcome"
    end
    resources :tickets
      

    resources :epipages
    resources :memberships
    resources :admissions
    resources :fruittypes
    resources :access_points
    resources :information
    
    resources :resources
    resources :postits
    resources :resource_requests
    
    namespace :members do
    end

    resources :epicenters

    get '/edit_engagement' => 'epicenters#edit_engagement'
    get '/edit_members' => 'epicenters#edit_members'
    get '/api' => 'epicenters#api'
    get '/new_api_token' => 'epicenters#new_api_token'
    get '/edit_meeting_time' => 'epicenters#edit_meeting_time'
    get '/review_plant' => 'epicenters#review_plant'
    get '/confirm_plant' => 'epicenters#confirm_plant'

    get '/members' => 'epicenters#members'
    get '/tshirts' => 'epicenters#tshirts'

    post '/give_tshirt' => 'epicenters#give_tshirt'

    
  end

  get '/info' => 'pages#info'
  get '/join_epicenter' => 'epicenters#join_epicenter'
  get '/leave_epicenter' => 'epicenters#leave_epicenter'
  post "/update_creditcard" => "subscriptions#update_creditcard"

  
  namespace :api, defaults: { format: 'json' } do
    
    
    namespace :v1, defaults: { format: 'json' } do
      resources :epicenters, param: :slug do
        resources :users
        post '/authenticate' => 'users#authenticate'
      end
      
      get '/stripe/public_key' => "stripe#get_public_key"
      post '/stripe/new_subscription_session' => "stripe#new_subscription_session"      
      post '/stripe/change_subscription_session' => "stripe#change_subscription_session"
      post '/stripe/update_card_session' => "stripe#update_card_session"
      post '/stripe/webhooks' => "stripe#webhooks"
      post '/stripe/webhooks/checkout' => "stripe#webhooks"
      
    end
  end

  


end
