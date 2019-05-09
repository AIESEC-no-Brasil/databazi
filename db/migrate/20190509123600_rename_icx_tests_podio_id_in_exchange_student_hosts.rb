class RenameIcxTestsPodioIdInExchangeStudentHosts < ActiveRecord::Migration[5.2]
  def change
    rename_column :exchange_student_hosts, :icx_tests_podio_id, :new_central_icx_podio_id
  end
end
