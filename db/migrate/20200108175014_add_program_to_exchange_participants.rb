class AddProgramToExchangeParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :program, :integer
  end
end
