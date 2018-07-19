Rails.application.routes.draw do
  resources :gt_participants, only: :create
  resources :gv_participants, only: :create
end
