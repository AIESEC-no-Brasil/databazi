class CreateGtParticipants < ActiveRecord::Migration[5.2]
  def change
    create_table :gt_participants do |t|
      t.integer :scholarity
      t.integer :experience

      t.timestamps
    end
  end
end
