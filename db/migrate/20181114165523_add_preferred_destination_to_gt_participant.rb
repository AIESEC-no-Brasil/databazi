class AddPreferredDestinationToGtParticipant < ActiveRecord::Migration[5.2]
  def change
    add_column :gt_participants, :preferred_destination, :Integer
  end
end
