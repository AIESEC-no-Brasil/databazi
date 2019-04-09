class AddWhenCanTravelToGtParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :gt_participants, :when_can_travel, :integer
  end
end
