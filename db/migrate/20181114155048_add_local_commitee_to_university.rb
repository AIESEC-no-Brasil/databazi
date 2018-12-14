class AddLocalCommiteeToUniversity < ActiveRecord::Migration[5.2]
  def change
    add_reference :universities, :local_committee, foreign_key: true
  end
end
