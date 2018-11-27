class GeParticipant < ApplicationRecord
  has_one :exchange_participant, as: :registerable, dependent: :destroy
  has_one :english_level, as: :englishable, dependent: :destroy
  has_one_attached :curriculum

  delegate :as_sqs, :fullname, :cellphone, :email, :birthdate,
           :first_name, :last_name, :scholarity,
           to: :exchange_participant, prefix: false

  accepts_nested_attributes_for :exchange_participant
  accepts_nested_attributes_for :english_level

  enum spanish_level: %i[none basic intermediate advanced fluent],
       _suffix: true

  enum when_can_travel: {
    as_soon_as_possible: 13,
    next_three_months: 14,
    next_six_months: 15,
    in_one_year: 16
  }

  enum preferred_destination: {
    brazil: 1,
    mexico: 2,
    peru: 3
  }

  validates :spanish_level, presence: true
  validates :when_can_travel, presence: true, if: :argentina?
  validates :preferred_destination, presence: true, if: :argentina?

  validate :correct_document_mime_type, if: :argentina?

  private

  def correct_document_mime_type
    if curriculum.attached? && !curriculum.content_type.in?(%w(application/pdf))
      errors.add(:curriculum, 'Must be a PDF file')
      curriculum.purge
    end
  end

end
