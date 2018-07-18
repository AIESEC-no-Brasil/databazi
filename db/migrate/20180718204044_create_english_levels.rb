class CreateEnglishLevels < ActiveRecord::Migration[5.2]
  def change
    create_table :english_levels do |t|
      t.integer :english_level
      t.string :englishable_type
      t.integer :englishable_id

      t.timestamps
    end
  end
end
