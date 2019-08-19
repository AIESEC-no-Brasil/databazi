class AddFieldsToExchangeParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :origin, :integer, default: 0
    add_column :exchange_participants, :profile_completeness, :boolean, default: false
  end
end
