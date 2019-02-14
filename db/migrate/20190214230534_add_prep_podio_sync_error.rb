class AddPrepPodioSyncError < ActiveRecord::Migration[5.2]
  def change
    add_column :expa_applications, :prep_podio_sync_error, :boolean, default: false
  end
end
