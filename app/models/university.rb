class University < ApplicationRecord
  scope :by_name, ->(name = '') do
    where('lower(name) LIKE ?', "%#{name.downcase}%")
      .where.not('name = ?', 'OUTRA')
  end

  has_many :exchange_participants
  belongs_to :local_committee, optional: true

  validates :podio_id, presence: true
  validates :name, presence: true
end
