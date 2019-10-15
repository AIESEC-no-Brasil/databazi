class ImpactBrazilReferral < ApplicationRecord
  validates :ep_expa_id, presence: true
  validates :application_expa_id, presence: true
  validates :opportunity_expa_id, presence: true
  validates :application_date, presence: true
end
