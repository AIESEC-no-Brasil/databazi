class AddScholarityToExchangeParticipant < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :scholarity, :integer
  end
end
