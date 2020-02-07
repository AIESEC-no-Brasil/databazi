class AddExchangeReasonToExchangeParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :exchange_reason, :string
  end
end
