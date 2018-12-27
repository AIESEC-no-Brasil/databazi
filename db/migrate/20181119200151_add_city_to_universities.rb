class AddCityToUniversities < ActiveRecord::Migration[5.2]
  def change
    add_column :universities, :city, :string
  end
end
