class CreateSurveyHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :survey_histories do |t|
      t.integer :podio_id
      t.jsonb :surveys

      t.timestamps
    end
  end
end
