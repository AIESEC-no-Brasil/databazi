class GtParticipant < ApplicationRecord
  has_one :exchange_participant, as: :registerable, dependent: :destroy
  has_one :english_level, as: :englishable, dependent: :destroy

  delegate :fullname, :cellphone, :email, :birthdate,
    to: :exchange_participant, prefix: false

  accepts_nested_attributes_for :exchange_participant
  accepts_nested_attributes_for :english_level

  enum experience: [:language, :marketing, :information_technology, :management],
    _suffix: true
  enum scholarity: [:graduating, :post_graduated, :almost_graduated, :graduated]
end
