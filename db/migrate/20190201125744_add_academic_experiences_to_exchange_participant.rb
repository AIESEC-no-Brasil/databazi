class AddAcademicExperiencesToExchangeParticipant < ActiveRecord::Migration[5.2]
  def change
    add_column :exchange_participants, :academic_backgrounds, :text, array: true
  end
end
