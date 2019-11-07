class AddRdstationUuidToExchangeParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :rdstation_uuid, :string
  end
end
