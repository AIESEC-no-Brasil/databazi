class AddPodioLastSynchedStatusToExpaApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :expa_applications, :podio_last_synched_status, :string
  end
end
