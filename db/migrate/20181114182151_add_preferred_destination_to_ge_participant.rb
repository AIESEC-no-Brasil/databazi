class AddPreferredDestinationToGeParticipant < ActiveRecord::Migration[5.2]
  def change
    add_column :ge_participants, :preferred_destination, :Integer
  end
end
