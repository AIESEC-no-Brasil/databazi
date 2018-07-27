class CollegeCourse < ApplicationRecord
  validates_presence_of :name, :podio_id

  has_many :exchange_participants

  def as_json
    {
      id: id,
      name: name,
      podio_id: podio_id
    }
  end
end
