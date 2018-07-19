class GvParticipant < ApplicationRecord
  has_one :exchange_participant, as: :registerable, dependent: :destroy

  delegate :fullname, :cellphone, :email, :birthdate,
    to: :exchange_participant, prefix: false

  accepts_nested_attributes_for :exchange_participant
end
