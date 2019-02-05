class AddAcademicExperienceToExpaApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :expa_applications, :academic_experience, :string
  end
end
