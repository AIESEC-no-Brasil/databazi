class AddRdstationSyncToExchangeParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :rdstation_sync, :boolean
  end
end
