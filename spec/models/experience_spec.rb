require 'rails_helper'

RSpec.describe Experience, type: :model do
  describe '#associations' do
    it { is_expected.to belong_to :gt_participant }
  end

  describe '#attributes' do
    it { is_expected.to respond_to :language }
    it { is_expected.to respond_to :marketing }
    it { is_expected.to respond_to :information_technology }
    it { is_expected.to respond_to :management }
  end
end
