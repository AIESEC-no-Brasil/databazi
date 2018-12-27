class CreateExpaApplications < ActiveRecord::Migration[5.2]
  def change
    create_table :expa_applications do |t|
      t.integer :expa_id
      t.string :status

      t.timestamps
    end
  end
end
