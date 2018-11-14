class GeParticipant < ApplicationRecord
  has_one :exchange_participant, as: :registerable, dependent: :destroy
  has_one :english_level, as: :englishable, dependent: :destroy

  delegate :as_sqs, :fullname, :cellphone, :email, :birthdate,
           :first_name, :last_name, :scholarity,
           to: :exchange_participant, prefix: false

  accepts_nested_attributes_for :exchange_participant
  accepts_nested_attributes_for :english_level

  enum spanish_level: %i[none basic intermediate advanced fluent],
       _suffix: true

  enum when_can_travel: %i[as_soon_as_possible next_three_months
                           next_six_months in_one_year]

  enum preferred_destination: %i[brazil mexico peru]

  validates :spanish_level, presence: true
  validates :when_can_travel, presence: true
  validates :preferred_destination, presence: true
end
