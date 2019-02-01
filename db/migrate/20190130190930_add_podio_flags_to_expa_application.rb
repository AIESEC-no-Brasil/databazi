class AddPodioFlagsToExpaApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :expa_applications, :podio_sent, :boolean
    add_column :expa_applications, :podio_sent_at, :datetime
  end
end
