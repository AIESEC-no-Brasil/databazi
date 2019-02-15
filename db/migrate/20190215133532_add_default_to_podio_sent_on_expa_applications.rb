class AddDefaultToPodioSentOnExpaApplications < ActiveRecord::Migration[5.2]
  def change
    change_column :expa_applications, :podio_sent, :boolean, default: false
  end
end
