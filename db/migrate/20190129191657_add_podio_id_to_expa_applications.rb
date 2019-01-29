class AddPodioIdToExpaApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :expa_applications, :podio_id, :integer
  end
end
