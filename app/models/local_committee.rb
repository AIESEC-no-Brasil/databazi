class LocalCommittee < ApplicationRecord
  scope :active, -> { where(active: true) }
  scope :brazilian, -> { joins(:member_committee).where(member_committees: { name: 'Brazil' }) }
  scope :argentinean, -> { joins(:member_committee).where(member_committees: { name: 'Argentina' }) }

  validates_presence_of :name, :expa_id

  has_many :exchange_participants
  has_many :universities
  has_many :university_local_committees

  belongs_to :member_committee, optional: true

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
