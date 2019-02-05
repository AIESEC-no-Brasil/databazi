class CreateMemberCommittees < ActiveRecord::Migration[5.2]
  def change
    create_table :member_committees do |t|
      t.string :name
      t.integer :expa_id
      t.integer :podio_id
      t.timestamps
    end
  end
end
