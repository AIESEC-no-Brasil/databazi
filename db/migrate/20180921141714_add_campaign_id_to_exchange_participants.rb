class AddCampaignIdToExchangeParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :campaign_id, :integer
  end
end
