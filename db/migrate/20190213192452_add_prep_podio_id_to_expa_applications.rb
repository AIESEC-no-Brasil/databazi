class AddPrepPodioIdToExpaApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :expa_applications, :prep_podio_id, :integer
  end
end
