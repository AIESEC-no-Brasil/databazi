class AddDatesToExpaApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :expa_applications, :applied_at, :date
    add_column :expa_applications, :accepted_at, :date
    add_column :expa_applications, :approved_at, :date
    add_column :expa_applications, :break_approved_at, :date
  end
end
