class AddResyncToExpaApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :expa_applications, :resync, :boolean, default: false
  end
end
