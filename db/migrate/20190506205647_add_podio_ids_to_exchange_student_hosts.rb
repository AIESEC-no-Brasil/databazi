class AddPodioIdsToExchangeStudentHosts < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_student_hosts, :icx_tests_podio_id, :bigint
    add_column :exchange_student_hosts, :central_icx_podio_id, :bigint
  end
end
