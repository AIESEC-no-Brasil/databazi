class Expa::Application < ApplicationRecord
  belongs_to :exchange_participant, foreign_key: :exchange_participant_id

  enum status: { open: 1, applied: 2, accepted: 3, approved: 4,
    break_approved: 5, rejected: 6 }
end
