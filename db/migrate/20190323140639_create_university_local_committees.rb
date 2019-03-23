class CreateUniversityLocalCommittees < ActiveRecord::Migration[5.2]
  def change
    create_table :university_local_committees do |t|
      t.references :university, foreign_key: true, index: true
      t.references :local_committee, foreign_key: true, index: true
      t.integer :program, index: true

      t.timestamps
    end
  end
end
