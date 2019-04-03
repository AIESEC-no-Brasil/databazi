class GvParticipant < ApplicationRecord
  ARGENTINEAN_WHEN_CAN_TRAVEL = %i[none as_soon_as_possible next_three_months
                                   next_six_months in_one_year]

  PERUVIAN_WHEN_CAN_TRAVEL = %i[as_soon_as_possible next_three_months
                                next_six_months informational_only]
  has_one :exchange_participant, as: :registerable, dependent: :destroy

  delegate :as_sqs, :fullname, :cellphone, :email, :birthdate,
           :first_name, :last_name, :scholarity,
           to: :exchange_participant, prefix: false

  accepts_nested_attributes_for :exchange_participant

  validates :when_can_travel, presence: true, if: :argentina?

  def when_can_travel_sym(when_can_travel)
    ENV['COUNTRY'] == 'arg' ? argentinean_when_can_travel(when_can_travel) : peruvian_when_can_travel(when_can_travel)
  end

  def argentinean_when_can_travel(when_can_travel)
    ExchangeParticipant::ARGENTINEAN_WHEN_CAN_TRAVEL[when_can_travel]
  end

  def peruvian_when_can_travel(when_can_travel)
    ExchangeParticipant::PERUVIAN_WHEN_CAN_TRAVEL[when_can_travel]
  end
end
