class AddHasErrorToExchangeParticipant < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :has_error, :boolean
  end
end
