class AddCollegeCourseIdToExchangeParticipants < ActiveRecord::Migration[5.2]
  def change
    add_reference :exchange_participants, :college_course, foreign_key: true
  end
end
