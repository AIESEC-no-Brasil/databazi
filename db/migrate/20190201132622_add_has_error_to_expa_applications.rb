class AddHasErrorToExpaApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :expa_applications, :has_error, :boolean, default: false
  end
end
