class AddFieldsToCollegeCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :college_courses, :expas_id, :bigint
    add_column :college_courses, :gv_podio_id, :integer
    add_column :college_courses, :ge_podio_id, :integer
    add_column :college_courses, :gt_podio_id, :integer
  end
end
