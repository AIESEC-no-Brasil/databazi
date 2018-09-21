class AddPasswordToExchangeParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :password, :string
  end
end
