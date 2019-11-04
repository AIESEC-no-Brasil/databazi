class AddOriginToExchangeParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :origin, :integer, default: :databazi
  end
end
