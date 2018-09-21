class GtParticipant < ApplicationRecord
  has_one :exchange_participant, as: :registerable, dependent: :destroy
  has_one :english_level, as: :englishable, dependent: :destroy
  has_one :experience, dependent: :destroy

  delegate :as_sqs, :fullname, :cellphone, :email, :birthdate,
           :first_name, :last_name, :scholarity,
           to: :exchange_participant, prefix: false

  accepts_nested_attributes_for :exchange_participant
  accepts_nested_attributes_for :english_level
  accepts_nested_attributes_for :experience
end
