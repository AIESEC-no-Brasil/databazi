class CreateImpactBrazilReferrals < ActiveRecord::Migration[5.2]
  def change
    create_table :impact_brazil_referrals do |t|
      t.bigint :ep_expa_id
      t.bigint :application_expa_id
      t.bigint :opportunity_expa_id
      t.datetime :application_date

      t.timestamps
    end
  end
end
