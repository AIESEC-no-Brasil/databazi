class AddSignupSourceToExchangeParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :signup_source, :integer
  end
end
