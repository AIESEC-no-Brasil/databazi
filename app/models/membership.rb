class Membership < ApplicationRecord
  belongs_to :college_course

  validates :fullname, presence: true
  validates :birthdate, presence: true
  validates :email, presence: true
  validates :cellphone, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :cellphone_contactable, presence: true
  validates :college_course, presence: true
  validates :nearest_committee, presence: true
end
