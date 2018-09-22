class CreateCampaigns < ActiveRecord::Migration[5.2]
  def change
    create_table :campaigns do |t|
      t.string :source
      t.string :medium
      t.string :campaign

      t.timestamps
    end
  end
end
