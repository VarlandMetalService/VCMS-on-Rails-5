Rails.application.routes.draw do

  resources :period
  resources :reason_codes

  resources :ipad, only: [:index] do
    collection do
      get :enter_pin
      get :employee_action
      get :change_pin
      get :logout
    end
  end

  resources :timeclock_records do
    collection do
      get :manage_records
      get :reason_codes
      get :clocked_in
    end
  end

  resources :shift_notes
  root                        'salt_spray_tests#index'
  get     'login'         =>  'sessions#new'
  post    'login'         =>  'sessions#create'
  delete  'logout'        =>  'sessions#destroy'

  resources :users
  resources :permissions

  resources :attachments
  resources :employee_notes
  resources :opto_messages

  resources :salt_spray_tests do
    collection do
      get 'archived_tests'
    end
    member do
      get 'add_comment'
      get 'edit_comment'
      get 'show_comments'
      delete 'delete_comment'
      get 'test_complete'
    end
  end

  get 'cabinet_readings' => 'salt_spray_tests#cabinet_readings', :as => 'cabinet_readings'

  resources :documents do
    collection do
      get :get_google_meta
    end
  end

  resources :categories do
    collection do
      post :move_up
      post :move_down
    end
  end

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

end
