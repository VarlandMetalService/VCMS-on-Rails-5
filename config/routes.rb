Rails.application.routes.draw do

  root                        'vcms#home'
  get     'login'         =>  'sessions#new'
  post    'login'         =>  'sessions#create'
  delete  'logout'        =>  'sessions#destroy'

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
  resources :permissions
  resources :users

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'

end
