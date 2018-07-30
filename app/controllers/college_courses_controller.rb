class CollegeCoursesController < ApplicationController
  expose :college_courses, -> { CollegeCourse.by_name(params[:name]) }

  def index
    render json: college_courses.as_json(only: [:id, :name])
  end
end
