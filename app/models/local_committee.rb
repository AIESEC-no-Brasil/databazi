class LocalCommittee < ApplicationRecord
  scope :active, -> { where(active: true) }

  validates_presence_of :name, :podio_id, :expa_id

  has_many :exchange_participants
  has_many :universities

  def as_json
    {
      id: id,
      name: name,
      podio_id: podio_id,
      expa_id: expa_id,
      active: active
    }
  end
end
