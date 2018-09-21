class RemovesExperienceFieldFromGtParticipants < ActiveRecord::Migration[5.2]
  def change
    remove_column :gt_participants, :experience
  end
end
