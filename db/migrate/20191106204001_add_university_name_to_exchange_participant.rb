class AddUniversityNameToExchangeParticipant < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :university_name, :string
  end
end
