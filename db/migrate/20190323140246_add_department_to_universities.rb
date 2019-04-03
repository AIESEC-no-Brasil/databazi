class AddDepartmentToUniversities < ActiveRecord::Migration[5.2]
  def change
    add_column :universities, :department, :string
  end
end
