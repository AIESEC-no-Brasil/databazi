class CreateGvParticipants < ActiveRecord::Migration[5.2]
  def change
    create_table :gv_participants do |t|
      t.timestamps
    end
  end
end
