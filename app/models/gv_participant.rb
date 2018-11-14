class GvParticipant < ApplicationRecord
  has_one :exchange_participant, as: :registerable, dependent: :destroy

  delegate :as_sqs, :fullname, :cellphone, :email, :birthdate,
           :first_name, :last_name, :scholarity,
           to: :exchange_participant, prefix: false

  accepts_nested_attributes_for :exchange_participant

  enum when_can_travel: %i[as_soon_as_possible next_three_months
                           next_six_months in_one_year]

  validates :when_can_travel, presence: true
end
