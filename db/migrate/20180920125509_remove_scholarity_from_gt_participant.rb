class RemoveScholarityFromGtParticipant < ActiveRecord::Migration[5.2]
  def change
    remove_column :gt_participants, :scholarity, :string
  end
end
