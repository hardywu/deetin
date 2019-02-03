Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :v1 do
    root to: 'application#root'
    resources :markets
    resources :orders, except: :destroy
    resources :trades, except: :destroy
    resources :otc_accounts, only: %i[index show]
    resources :transfers, except: %i[update destroy]
    resources :documents
    resources :phones
    post 'auth/signup', to: 'auth#signup'
    post 'auth/signin', to: 'auth#signin'
    post 'auth/phone_vcode', to: 'auth#phone_vcode'
    get 'peatio_orders', to: 'peatio_orders#index'
  end
end
