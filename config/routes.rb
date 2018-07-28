Rails.application.routes.draw do
  mount SwaggerUiEngine::Engine, at: "/api_docs"

  resources :universities, only: :index
  resources :college_courses, only: :index
  resources :local_committees, only: :index
  resources :ge_participants, only: :create
  resources :gt_participants, only: :create
  resources :gv_participants, only: :create
end
