Rails.application.routes.draw do
  resources :gv_participants, only: :create
end
