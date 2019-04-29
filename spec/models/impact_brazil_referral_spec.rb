require 'rails_helper'

RSpec.describe ImpactBrazilReferral, type: :model do
  describe '#attributes' do
    it { is_expected.to respond_to :ep_expa_id }
    it { is_expected.to respond_to :application_expa_id }
    it { is_expected.to respond_to :opportunity_expa_id }
    it { is_expected.to respond_to :application_date }
  end

  describe '#validations' do
    it { is_expected.to validate_presence_of :ep_expa_id }
    it { is_expected.to validate_presence_of :application_expa_id }
    it { is_expected.to validate_presence_of :opportunity_expa_id }
    it { is_expected.to validate_presence_of :application_date }
  end
end
