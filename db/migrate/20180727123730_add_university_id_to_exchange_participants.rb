class AddUniversityIdToExchangeParticipants < ActiveRecord::Migration[5.2]
  def change
    add_reference :exchange_participants, :university, foreign_key: true
  end
end
