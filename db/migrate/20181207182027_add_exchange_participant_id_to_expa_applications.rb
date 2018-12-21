class AddExchangeParticipantIdToExpaApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :expa_applications, :exchange_participant_id, :integer
  end
end
