class ExchangeParticipant < ApplicationRecord
  validates :fullname, presence: true
  validates :cellphone, presence: true
  validates :email, presence: true,
                    uniqueness: true
  validates :birthdate, presence: true

  belongs_to :registerable, polymorphic: true
end
