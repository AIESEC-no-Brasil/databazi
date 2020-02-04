class AddScholarityStageToExchangeParticipant < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :scholarity_stage, :string
  end
end
