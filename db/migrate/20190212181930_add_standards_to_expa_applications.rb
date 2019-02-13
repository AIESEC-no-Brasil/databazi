class AddStandardsToExpaApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :expa_applications, :standards, :jsonb
  end
end
