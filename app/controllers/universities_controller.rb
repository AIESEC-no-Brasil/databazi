class UniversitiesController < ApplicationController
  expose :universities, -> { University.by_name(params[:name]) }

  def index
    render json: universities.as_json(only: %i[id name])
  end
end
