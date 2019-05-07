class AddCentralIcxPodioIdToExchangeStudentHosts < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_student_hosts, :central_icx_podio_id, :bigint
    remove_column :exchange_student_hosts, :exchange_student_hosts
  end
end
