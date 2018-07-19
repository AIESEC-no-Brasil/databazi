Rails.application.routes.draw do
  resources :ge_participants, only: :create
  resources :gt_participants, only: :create
  resources :gv_participants, only: :create
end
