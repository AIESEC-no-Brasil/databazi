class AddExpaIdToUniversity < ActiveRecord::Migration[5.2]
  def change
    add_column :universities, :expa_id, :bigint
  end
end
