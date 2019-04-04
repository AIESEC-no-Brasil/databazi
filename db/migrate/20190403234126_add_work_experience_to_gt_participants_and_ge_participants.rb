class AddWorkExperienceToGtParticipantsAndGeParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :gt_participants, :work_experience, :integer
    add_column :ge_participants, :work_experience, :integer
  end
end
