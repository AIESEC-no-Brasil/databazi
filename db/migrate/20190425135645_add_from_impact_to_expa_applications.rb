class AddFromImpactToExpaApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :expa_applications, :from_impact, :boolean, default: false
  end
end
