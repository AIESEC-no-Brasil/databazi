class GtParticipant < ApplicationRecord
  has_one :exchange_participant, as: :registerable, dependent: :destroy

  delegate :fullname, :cellphone, :email, :birthdate,
    to: :exchange_participant, prefix: false

  enum experience: [:language, :marketing, :information_technology, :management],
    _suffix: true
  enum scholarity: [:graduating, :post_graduated, :almost_graduated, :graduated]
end
