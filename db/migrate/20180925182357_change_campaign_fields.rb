class ChangeCampaignFields < ActiveRecord::Migration[5.2]
  def change
    rename_column :campaigns, :source, :utm_source
    rename_column :campaigns, :medium, :utm_medium
    rename_column :campaigns, :campaign, :utm_campaign
    add_column :campaigns, :utm_term, :string
    add_column :campaigns, :utm_content, :string
  end
end
