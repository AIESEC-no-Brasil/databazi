class AddOpportunityDateToExpaApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :expa_applications, :opportunity_date, :datetime
  end
end
