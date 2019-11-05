class AddSubproductToGtParticipant < ActiveRecord::Migration[5.2]
  def change
    add_column :gt_participants, :subproduct, :integer
  end
end
