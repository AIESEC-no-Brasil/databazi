class AddFinishedToExpaApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :expa_applications, :finished, :boolean, default: false
  end
end
