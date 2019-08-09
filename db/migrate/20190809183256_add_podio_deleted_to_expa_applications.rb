class AddPodioDeletedToExpaApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :expa_applications, :podio_deleted, :boolean
  end
end
