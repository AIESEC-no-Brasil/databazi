class LocalCommittee < ApplicationRecord
  validates_presence_of :name, :podio_id, :expa_id

  has_many :exchange_participants
end
