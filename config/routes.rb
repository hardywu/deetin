Rails.application.routes.draw do
  resources :transfers
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :v1 do
    root to: 'application#root'
    resources :markets
    resources :orders, except: :destroy
    resources :trades, except: :destroy
    resources :otc_accounts, only: %i(index show)
    resources :transfers, except: %i(update destroy)
  end
end
