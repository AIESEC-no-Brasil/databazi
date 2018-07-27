class LocalCommittee < ApplicationRecord
  validates_presence_of :name, :podio_id, :expa_id

  has_many :exchange_participants

  def as_json
    {
      id: id,
      name: name,
      podio_id: podio_id,
      expa_id: expa_id
    }
  end
end
