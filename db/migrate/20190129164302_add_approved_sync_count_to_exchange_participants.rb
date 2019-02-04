class AddApprovedSyncCountToExchangeParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :approved_sync_count, :integer, default: 1
  end
end
