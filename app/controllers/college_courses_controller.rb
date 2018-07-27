class CollegeCoursesController < ApplicationController
  expose :college_courses, -> { CollegeCourse.all }

  def index
    render json: college_courses.as_json
  end
end
