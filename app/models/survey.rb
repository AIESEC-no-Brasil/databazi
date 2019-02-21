class Survey < ApplicationRecord
  validates :collector, presence: true
  validates :status, presence: true
  validates :name, presence: true

  enum status: %i[approved realized finished break_approval realization_broken]
end
