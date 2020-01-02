class AddNearestCommitteeToMemberships < ActiveRecord::Migration[5.2]
  def change
    add_column :memberships, :nearest_committee, :integer
  end
end
