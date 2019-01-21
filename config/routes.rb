Rails.application.routes.draw do
  resources :transfers
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :v1 do
    root to: 'application#root'
    resources :markets
    resources :orders, except: :destroy
    resources :trades, except: :destroy
    resources :otc_accounts, only: %i[index show]
    resources :transfers, except: %i[update destroy]
    post 'users/create_by_phone', to: 'users#create'
    post 'users/phone_vcode', to: 'users#phone_vcode'
    get 'peatio_orders', to: 'peatio_orders#index'
  end
end
