class GeParticipant < ApplicationRecord
  has_one :exchange_participant, as: :registerable, dependent: :destroy
  has_one :english_level, as: :englishable, dependent: :destroy

  delegate :as_sqs, :fullname, :cellphone, :email, :birthdate,
           :first_name, :last_name,
           to: :exchange_participant, prefix: false

  accepts_nested_attributes_for :exchange_participant
  accepts_nested_attributes_for :english_level

  enum spanish_level: %i[none basic intermediate advanced fluent],
       _suffix: true

  validates :spanish_level, presence: true
end
