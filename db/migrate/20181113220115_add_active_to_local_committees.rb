class AddActiveToLocalCommittees < ActiveRecord::Migration[5.2]
  def change
    add_column :local_committees, :active, :boolean, default: true
  end
end
