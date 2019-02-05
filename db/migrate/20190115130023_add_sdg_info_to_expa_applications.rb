class AddSdgInfoToExpaApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :expa_applications, :sdg_target_index, :integer
    add_column :expa_applications, :sdg_goal_index, :integer
  end
end
