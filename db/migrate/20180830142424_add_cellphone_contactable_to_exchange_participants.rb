class AddCellphoneContactableToExchangeParticipants <
  ActiveRecord::Migration[5.2]

  def up
    add_column :exchange_participants, :cellphone_contactable, :boolean,
               default: false
  end

  def down
    remove_column :exchange_participants, :cellphone_contactable
  end
end
