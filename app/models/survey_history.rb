class SurveyHistory < ApplicationRecord
  validates :podio_id, presence: true
end
