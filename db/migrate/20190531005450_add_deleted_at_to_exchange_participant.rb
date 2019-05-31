class AddDeletedAtToExchangeParticipant < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :deleted_at, :datetime
  end
end
