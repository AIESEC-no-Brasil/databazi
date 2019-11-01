class AddSignupSourceToExchangeParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :signup_source, :integer, default: 0
  end
end
