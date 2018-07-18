class GeParticipant < ApplicationRecord
  has_one :exchange_participant, as: :registerable, dependent: :destroy
  has_one :english_level, as: :englishable, dependent: :destroy

  delegate :fullname, :cellphone, :email, :birthdate,
    to: :exchange_participant, prefix: false

  enum spanish_level: [:none, :basic, :intermediate, :advanced, :fluent],
    _suffix: true
end
