class CollegeCourse < ApplicationRecord
  scope :by_name, ->(name = nil) { where('unaccent(name) ILIKE unaccent(?)', "%#{(name)}%") }

  has_many :exchange_participants

  validates :podio_id, presence: true
  validates :name, presence: true
end
