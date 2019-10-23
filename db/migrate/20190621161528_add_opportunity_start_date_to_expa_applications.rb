class AddOpportunityStartDateToExpaApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :expa_applications, :opportunity_start_date, :datetime
  end
end
