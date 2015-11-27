Rails.application.routes.draw do

  mount Ckeditor::Engine => '/ckeditor'

  scope '(:locale)', :locale => /en|ru/ do

    devise_for :users, :controllers => {:registrations => 'registrations'}
    resources :workshops do
      resources :comments
      get 'info' => 'workshops#info', :on => :member
    end
    resources :users, only: [:show]

    root 'index#index'
    get 'profile' => 'users#profile', as: 'profile'
    get 'contacts' => 'index#contacts'
    get 'org_committee' => 'index#org_committee'
    get 'why_kfu' => 'index#why_kfu'
    get 'information_letter' => 'index#information_letter'

    resources :listener_requests, only: [:new, :create] do
      get 'success' => 'listener_requests#success', :on => :member
    end

    resources :special_guests, only: [:show] do
      get 'speakers' => 'special_guests#speakers', :on => :collection
      get 'guests' => 'special_guests#guests', :on => :collection
    end

    resources :sections, only: [:show]

    # resources :articles

    namespace :admin do
      resources :users, only: [:new, :index, :create, :destroy]
      resources :sponsor_categories
      resources :sponsors
      resources :page_contents
      resources :special_guests
      resources :sections
      resources :events
      get 'placement' => 'placement#index'
      post 'placement' => 'placement#update'
      resources :workshops do
        put 'approve' => 'workshops#approve', on: :member
        put 'deny' => 'workshops#deny', on: :member
        resources :comments
      end
      resources :listener_requests, only: [:index] do
        get 'excel' => 'listener_requests#excel', :on => :collection
      end
    end
  end


end
