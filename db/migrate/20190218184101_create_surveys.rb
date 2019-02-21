class CreateSurveys < ActiveRecord::Migration[5.2]
  def change
    create_table :surveys do |t|
      t.string :collector
      t.integer :status

      t.timestamps
    end
  end
end
