Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :v1 do
    namespace :admin do
      resources :users
      resources :accounts
      resources :markets
      resources :accounts, only: %i[index show]
    end

    root to: 'application#root'
    resources :markets, only: %i[index show]
    resources :orders, except: :destroy
    resources :trades, except: :destroy do
      collection do
        post 'quick_bid'
      end
      member do
        patch 'await'
        patch 'done'
      end
    end
    resources :accounts, only: %i[index show]
    resources :transfers, except: %i[update destroy]
    resources :documents
    resources :phones
    resources :profiles
    resources :users do
      member do
        post 'listen'
      end
    end
    resources :payments
    resources :positions, only: %i[index]
    post 'auth/signup', to: 'auth#signup'
    post 'auth/signin', to: 'auth#signin'
    post 'auth/phone_vcode', to: 'auth#phone_vcode'
    get 'peatio_orders', to: 'peatio_orders#index'

    mount ActionCable.server => '/cable'
  end
end
