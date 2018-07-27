class UniversitiesController < ApplicationController
  expose :universities, -> { University.all }

  def index
    render json: universities.as_json
  end
end
