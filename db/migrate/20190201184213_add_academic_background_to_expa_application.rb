class AddAcademicBackgroundToExpaApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :expa_applications, :academic_backgrounds, :text, array: true
    remove_column :expa_applications, :academic_experience
  end
end
