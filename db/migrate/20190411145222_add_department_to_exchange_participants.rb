class AddDepartmentToExchangeParticipants < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :department, :string
  end
end
