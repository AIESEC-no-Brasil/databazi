class AddFieldsToExchangeParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :education_level, :text, array: true
    add_column :exchange_participants, :gender, :string
    add_column :exchange_participants, :programmes, :string
    add_column :exchange_participants, :lc_alignment, :string
    add_column :exchange_participants, :managers, :string
    add_column :exchange_participants, :opportunity_applications_count, :integer
  end
end
