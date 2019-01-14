class AddOpportunityNameToExpaApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :expa_applications, :opportunity_name, :string
  end
end
