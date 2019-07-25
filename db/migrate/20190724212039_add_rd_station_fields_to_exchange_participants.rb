class AddRdStationFieldsToExchangeParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :rdstation_opportunity, :boolean, default: false
    add_column :exchange_participants, :rdstation_lifecycle_stage, :integer, default: 0
    add_column :exchange_participants, :rdstation_uuid, :string
  end
end
