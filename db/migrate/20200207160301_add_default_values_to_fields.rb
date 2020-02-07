class AddDefaultValuesToFields < ActiveRecord::Migration[5.2]
  def change
    change_column :exchange_participants, :expa_id_sync, :boolean, default: true
    change_column :exchange_participants, :has_error, :boolean, default: false
  end
end
