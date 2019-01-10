class AddExpaEpIdToExpaApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :expa_applications, :expa_ep_id, :integer
  end
end
