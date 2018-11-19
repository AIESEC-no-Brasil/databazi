class AddWhenCanTravelToGvParticipant < ActiveRecord::Migration[5.2]
  def change
    add_column :gv_participants, :when_can_travel, :Integer
  end
end
