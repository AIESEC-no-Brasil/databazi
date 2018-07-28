class University < ApplicationRecord
  has_many :exchange_participants
  
  ##
  # :singleton-method:
  # Returns all Universities which contains in its name the given string 
  # (case-insensitive)
  # Will otherwise return all Universities if no param is given, due to
  # LIKE's wildcard % (zero, one or multiple characters)
  scope :by_name, -> (name = nil) { where("lower(name) LIKE ?", "%#{name}%") } 

  validates_presence_of :name, :podio_id
end
