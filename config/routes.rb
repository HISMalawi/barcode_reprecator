Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get '/', to: 'home#index'
  get '/print_barcode', to: 'home#print_barcode'
  post 'print', to: 'home#print'
end
