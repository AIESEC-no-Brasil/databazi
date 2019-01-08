class CreateSyncParams < ActiveRecord::Migration[5.2]
  def change
    create_table :sync_params do |t|
      t.datetime :podio_application_status_last_sync

      t.timestamps
    end
  end
end
