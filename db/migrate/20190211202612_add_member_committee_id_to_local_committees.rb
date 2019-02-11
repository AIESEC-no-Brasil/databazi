class AddMemberCommitteeIdToLocalCommittees < ActiveRecord::Migration[5.2]
  def change
    add_column :local_committees, :member_committee_id, :integer
  end
end
