class RemoveOpportunityIdOfExpaApplications < ActiveRecord::Migration[5.2]
  def change
    remove_column :expa_applications, :opportunity_expa_id
  end
end
