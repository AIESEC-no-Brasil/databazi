class ChangeDateColumnsOfExpaApplications < ActiveRecord::Migration[5.2]
  def change
    change_column :expa_applications, :applied_at, :datetime
    change_column :expa_applications, :accepted_at, :datetime
    change_column :expa_applications, :approved_at, :datetime
    change_column :expa_applications, :break_approved_at, :datetime
  end
end
