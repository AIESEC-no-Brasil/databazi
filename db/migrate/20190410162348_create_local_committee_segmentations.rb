class CreateLocalCommitteeSegmentations < ActiveRecord::Migration[5.2]
  def change
    create_table :local_committee_segmentations do |t|
      t.bigint :origin_local_committee_id
      t.bigint :destination_local_committee_id
      t.integer :program

      t.timestamps
    end
  end
end
