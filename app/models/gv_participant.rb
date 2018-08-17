class GvParticipant < ApplicationRecord
  has_one :exchange_participant, as: :registerable, dependent: :destroy

  delegate :as_sqs, :fullname, :cellphone, :email, :birthdate,
           :first_name, :last_name,
           to: :exchange_participant, prefix: false

  accepts_nested_attributes_for :exchange_participant
end
