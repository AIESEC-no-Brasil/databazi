class AddDefaultValueToSignupSource < ActiveRecord::Migration[5.2]
  def change
  change_column :exchange_participants, :signup_source, :integer, default: 0
  end
end
