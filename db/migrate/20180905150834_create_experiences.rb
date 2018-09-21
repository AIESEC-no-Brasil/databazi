class CreateExperiences < ActiveRecord::Migration[5.2]
  def change
    create_table :experiences do |t|
      t.boolean :language, default: false
      t.boolean :marketing, default: false
      t.boolean :information_technology, default: false
      t.boolean :management, default: false
      t.references :gt_participant

      t.timestamps
    end
  end
end
