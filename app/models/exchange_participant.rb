class ExchangeParticipant < ApplicationRecord
  validates :fullname, presence: true
  validates :cellphone, presence: true
  validates :email, presence: true,
                    uniqueness: true
  validates :birthdate, presence: true

  belongs_to :registerable, polymorphic: true
  belongs_to :local_committee
  belongs_to :university
  belongs_to :college_course
end
