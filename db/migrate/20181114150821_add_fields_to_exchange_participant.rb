class AddFieldsToExchangeParticipant < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :other_university, :string
  end
end
