Rails.application.routes.draw do
  mount SwaggerUiEngine::Engine, at: "/api_docs"

  root 'empty#index'
  get 'exchange_participants' => 'exchange_participants#validate_email'

  resources :universities, only: :index
  resources :college_courses, only: :index
  resources :local_committees, only: :index
  resources :ge_participants, only: :create
  resources :gt_participants, only: :create
  resources :gv_participants, only: :create
  resources :exchange_student_hosts, only: :create
  resources :memberships, only: :create
end
