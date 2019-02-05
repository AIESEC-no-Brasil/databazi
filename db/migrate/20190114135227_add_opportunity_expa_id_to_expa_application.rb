class AddOpportunityExpaIdToExpaApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :expa_applications, :opportunity_expa_id, :integer
  end
end
