class GtParticipant < ApplicationRecord
  ARGENTINEAN_WHEN_CAN_TRAVEL = %i[none as_soon_as_possible next_three_months
                                   next_six_months in_one_year]

  PERUVIAN_WHEN_CAN_TRAVEL = %i[as_soon_as_possible next_three_months
                                next_six_months informational_only]

  has_one :exchange_participant, as: :registerable, dependent: :destroy
  has_one :english_level, as: :englishable, dependent: :destroy
  has_one :experience, dependent: :destroy
  has_one_attached :curriculum

  delegate :as_sqs, :fullname, :cellphone, :email, :birthdate,
           :first_name, :last_name, :scholarity,
           to: :exchange_participant, prefix: false

  accepts_nested_attributes_for :exchange_participant
  accepts_nested_attributes_for :english_level
  accepts_nested_attributes_for :experience

  enum preferred_destination: { none: 0, brazil: 4, colombia: 5, costa_rica: 6, hungary: 7,
                                india: 8, mexico: 9, panama: 10, romania: 11 }, _suffix: true

  enum work_experience: %i[none more_than_6_months more_than_a_year], _suffix: true

  validates :preferred_destination, presence: true, if: :argentina?

  validate :correct_document_mime_type, if: :argentina?

  def when_can_travel_sym(when_can_travel)
    ENV['COUNTRY'] == 'arg' ? argentinean_when_can_travel(when_can_travel) : peruvian_when_can_travel(when_can_travel)
  end

  def argentinean_when_can_travel(when_can_travel)
    ExchangeParticipant::ARGENTINEAN_WHEN_CAN_TRAVEL[when_can_travel]
  end

  def peruvian_when_can_travel(when_can_travel)
    ExchangeParticipant::PERUVIAN_WHEN_CAN_TRAVEL[when_can_travel]
  end

  private

  def correct_document_mime_type
    if curriculum.attached? &&
        !curriculum.content_type.in?(%w[application/pdf])
      errors.add(:curriculum, 'Must be a PDF file')
      curriculum.purge
    end
  end
end
