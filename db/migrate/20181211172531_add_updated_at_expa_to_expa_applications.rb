class AddUpdatedAtExpaToExpaApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :expa_applications, :updated_at_expa, :datetime
  end
end
