class Expa::Application < ApplicationRecord
  belongs_to :exchange_participant, foreign_key: :exchange_participant_id
  belongs_to :exchange_participant, foreign_key: :current_aplication_id

  enum status: { open: 1, applied: 5, accepted: 16, approved: 6 }
end
