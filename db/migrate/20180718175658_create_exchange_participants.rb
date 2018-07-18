class CreateExchangeParticipants < ActiveRecord::Migration[5.2]
  def change
    create_table :exchange_participants do |t|
      t.string :fullname
      t.string :cellphone
      t.string :email
      t.datetime :birthdate

      t.timestamps
    end
  end
end
