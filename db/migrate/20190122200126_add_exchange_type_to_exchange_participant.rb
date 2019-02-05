class AddExchangeTypeToExchangeParticipant < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :exchange_type, :integer, default: 0
  end
end
