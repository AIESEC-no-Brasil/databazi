class ExchangeStudentHost < ApplicationRecord
  validates :fullname, presence: true
  validates :email, presence: true
  validates :cellphone, presence: true
  validates :zipcode, presence: true
  validates :neighborhood, presence: true
  validates :city, presence: true
  validates :state, presence: true

   belongs_to :local_committee

   def as_sqs
    { exchange_student_host_id: id }
  end
end
