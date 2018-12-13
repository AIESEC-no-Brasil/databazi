class ChangeExpaApplicationStatusToInteger < ActiveRecord::Migration[5.2]
  def up
    change_column :expa_applications, :status, 'integer USING CAST(status AS integer)'
  end

  def down
    change_column :expa_applications, :status, :string
  end
end
