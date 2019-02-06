class AddHomeLcToExpaApplication < ActiveRecord::Migration[5.2]
  def change
    add_reference(:expa_applications, :home_lc, foreign_key: {to_table: :local_committees})
    add_reference(:expa_applications, :host_lc, foreign_key: {to_table: :local_committees})
  end
end
