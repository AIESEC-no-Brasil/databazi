class GvParticipant < ApplicationRecord
  has_one :exchange_participant, as: :registerable, dependent: :destroy

  delegate :as_sqs, :fullname, :cellphone, :email, :birthdate,
           :first_name, :last_name, :scholarity,
           to: :exchange_participant, prefix: false

  accepts_nested_attributes_for :exchange_participant

  enum when_can_travel: {
    as_soon_as_possible: 13,
    next_three_months: 14,
    next_six_months: 15,
    in_one_year: 16
  }

  validates :when_can_travel, presence: true, if: :argentina?
end
