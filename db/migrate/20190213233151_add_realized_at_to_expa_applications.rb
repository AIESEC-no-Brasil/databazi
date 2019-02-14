class AddRealizedAtToExpaApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :expa_applications, :realized_at, :datetime
  end
end
