class University < ApplicationRecord
  scope :by_name, ->(name = '') { query_by_name(name) }

  has_many :exchange_participants
  belongs_to :local_committee, optional: true

  validates :podio_id, presence: true
  validates :name, presence: true

  def self.query_by_name(name)
    where('unaccent(name) ILIKE unaccent(?)', "%#{name}%")
      .where.not('name = ?', 'OUTRA')
      .where.not('unaccent(name) ILIKE unaccent(?)', 'otras - %')
  end
end
