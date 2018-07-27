class AddLocalCommitteeIdToExchangeParticipants < ActiveRecord::Migration[5.2]
  def change
    add_reference :exchange_participants, :local_committee, foreign_key: true
  end
end
