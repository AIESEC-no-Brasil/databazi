class AddPendingSyncToExchangeParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :pending_sync, :boolean, default: false
  end
end
