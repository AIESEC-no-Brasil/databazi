class AddUpdatedAtExpaToExchangeParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :updated_at_expa, :datetime
  end
end
