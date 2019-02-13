class AddCompletedAtToExpaApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :expa_applications, :completed_at, :datetime
  end
end
