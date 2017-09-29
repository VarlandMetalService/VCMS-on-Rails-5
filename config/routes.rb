Rails.application.routes.draw do


  root                        'vcms#home'
  get     'login'         =>  'sessions#new'
  post    'login'         =>  'sessions#create'
  delete  'logout'        =>  'sessions#destroy'

  resources :users
  resources :permissions

  resources :attachments
  resources :employee_notes
  resources :opto_messages

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

end
