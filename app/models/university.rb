class University < ApplicationRecord
  scope :by_name, ->(name = nil) { where('lower(name) LIKE ?', "%#{name}%") }

  has_many :exchange_participants

  validates :podio_id, presence: true
  validates :name, presence: true
end
