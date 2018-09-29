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

  describe '#methods' do
    describe '#for_podio' do
      let(:gt_participant) { create(:gt_participant) }
      let(:experience) do
        create(:experience, gt_participant: gt_participant,
          marketing: true, language: true
          )
      end

      it 'returns an array containing matching podio IDs' do
        expect(experience.for_podio).to match_array([1, 4])
      end
    end
  end
end
