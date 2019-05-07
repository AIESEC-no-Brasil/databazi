class CreateExchangeStudentHosts < ActiveRecord::Migration[5.2]
  def change
    create_table :exchange_student_hosts do |t|
      t.string :fullname
      t.string :email
      t.string :cellphone
      t.string :zipcode
      t.string :neighborhood
      t.string :city
      t.string :state
      t.boolean :cellphone_contactable, default: false
      t.bigint :icx_tests_podio_id
      t.bigint :exchange_student_hosts
      t.references :local_committee

       t.timestamps
    end
  end
end
