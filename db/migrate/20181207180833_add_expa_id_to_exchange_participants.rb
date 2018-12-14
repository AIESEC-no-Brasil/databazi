class AddExpaIdToExchangeParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :expa_id, :integer
  end
end
