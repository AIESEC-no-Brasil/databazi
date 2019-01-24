class AddStatusToExchangeParticipant < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :status, :integer
  end
end
