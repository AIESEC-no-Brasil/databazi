class AddsFieldsToExpaApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :expa_applications, :product, :integer
    add_column :expa_applications, :podio_id, :integer
    add_column :expa_applications, :tnid, :integer
  end
end
