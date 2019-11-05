class GtParticipant < ApplicationRecord
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
                                india: 8, mexico: 9, panama: 10, romania: 11, turkey: 12 }, _suffix: true

  enum work_experience: %i[none less_than_3_months more_than_3_months more_than_6_months more_than_a_year], _suffix: true

  enum subproduct: %i[business_administration, marketing, teaching, other], _suffix: true

  validates :preferred_destination, presence: true, if: :argentina?

  validate :correct_document_mime_type, if: :argentina?

  private

  def correct_document_mime_type
    if curriculum.attached? &&
        !curriculum.content_type.in?(%w[application/pdf])
      errors.add(:curriculum, 'Must be a PDF file')
      curriculum.purge
    end
  end
end
