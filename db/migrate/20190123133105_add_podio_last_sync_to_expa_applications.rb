class AddPodioLastSyncToExpaApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :expa_applications, :podio_last_sync, :datetime
  end
end
