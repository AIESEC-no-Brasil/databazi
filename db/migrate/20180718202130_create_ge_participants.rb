class CreateGeParticipants < ActiveRecord::Migration[5.2]
  def change
    create_table :ge_participants do |t|
      t.integer :spanish_level

      t.timestamps
    end
  end
end
