class AddWhenCanTravelToGeParticipant < ActiveRecord::Migration[5.2]
  def change
    add_column :ge_participants, :when_can_travel, :Integer
  end
end
