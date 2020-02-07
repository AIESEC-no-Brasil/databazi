class AddExpaIdSyncToExchangeParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :expa_id_sync, :boolean
  end
end
