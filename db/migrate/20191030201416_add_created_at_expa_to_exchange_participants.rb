class AddCreatedAtExpaToExchangeParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :created_at_expa, :datetime
  end
end
