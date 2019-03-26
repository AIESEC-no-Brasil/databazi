class AddReferralTypeToExchangeParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :referral_type, :integer
  end
end
