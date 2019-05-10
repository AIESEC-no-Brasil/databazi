class ChangeExchangeStudentHostFields < ActiveRecord::Migration[5.2]
  def change
    remove_column :exchange_student_hosts, :central_icx_podio_id
    rename_column :exchange_student_hosts, :new_central_icx_podio_id, :podio_id
  end
end
