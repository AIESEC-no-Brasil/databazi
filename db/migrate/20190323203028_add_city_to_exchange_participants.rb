class AddCityToExchangeParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :city, :string
  end
end
