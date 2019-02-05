class AddHomeMcToExpaApplications < ActiveRecord::Migration[5.2]
  def change
    add_reference(:expa_applications, :home_mc, foreign_key: {to_table: :member_committees})
  end
end
