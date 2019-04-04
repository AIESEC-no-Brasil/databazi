class CorrectsFieldFromCollegeCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :college_courses, :expa_id, :bigint
    remove_column :college_courses, :expas_id
  end
end
