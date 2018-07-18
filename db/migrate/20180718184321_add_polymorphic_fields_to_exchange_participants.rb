class AddPolymorphicFieldsToExchangeParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :registerable_id, :integer
    add_column :exchange_participants, :registerable_type, :string
    add_index :exchange_participants, [:registerable_type, :registerable_id],
      name: 'registerable_index_on_exchange_participants'
  end

end
