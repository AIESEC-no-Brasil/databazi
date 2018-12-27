class MovePodioIdToExchangeParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :podio_id, :integer
    remove_column :ge_participants, :podio_id
    remove_column :gv_participants, :podio_id
    remove_column :gt_participants, :podio_id
  end
end
