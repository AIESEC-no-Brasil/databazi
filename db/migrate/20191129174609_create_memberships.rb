class CreateMemberships < ActiveRecord::Migration[5.2]
  def change
    create_table :memberships do |t|
      t.string :fullname
      t.string :cellphone
      t.date :birthdate
      t.string :email
      t.string :city
      t.string :state
      t.boolean :cellphone_contactable
      t.references :college_course, foreign_key: true
      t.references :local_committee, foreign_key: true

      t.timestamps
    end
  end
end
