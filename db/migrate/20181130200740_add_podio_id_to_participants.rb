class AddPodioIdToParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :gv_participants, :podio_id, :integer
    add_column :ge_participants, :podio_id, :integer
    add_column :gt_participants, :podio_id, :integer
  end
end
