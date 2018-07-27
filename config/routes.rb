Rails.application.routes.draw do
  resources :college_courses, only: :index
  resources :local_committees, only: :index
  resources :ge_participants, only: :create
  resources :gt_participants, only: :create
  resources :gv_participants, only: :create
end
