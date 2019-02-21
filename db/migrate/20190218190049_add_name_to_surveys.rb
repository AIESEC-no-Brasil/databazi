class AddNameToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :name, :string
  end
end
