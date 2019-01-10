class Expa::Application < ApplicationRecord
  belongs_to :exchange_participant, foreign_key: :exchange_participant_id, optional: true

  enum status: { open: 1, applied: 2, accepted: 3, approved: 4,
    break_approved: 5, rejected: 6, withdrawn: 7,
                 realized: 100, realization_broken: 101 }
end
