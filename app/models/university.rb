class University < ApplicationRecord
  scope :by_name, ->(name = '') { query_by_name(name) }

  has_many :exchange_participants
  belongs_to :local_committee, optional: true

  validates :podio_id, presence: true
  validates :name, presence: true

  def self.query_by_name(name)
    where('lower(name) LIKE ?', "%#{name.downcase}%")
      .where.not('name = ?', 'OUTRA')
  end
end
