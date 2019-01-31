require 'rails_helper'

RSpec.describe Expa::Application, type: :model do
  describe '#scopes' do
    context 'first_approved_at' do
      let(:application) { create(:application, approved_at: 5.day.ago) }
      let(:other_applications) { create_list(:application, 4, approved_at: 3.days.ago) }

      it 'returns the oldest approved application' do
        expect(Expa::Application.first_approved_at).to eq [application]
      end
    end

    context 'approveds' do
      let(:first_approved) { create(:application, approved_at: 3.days.ago) }
      let(:second_approved) { create(:application, approved_at: 1.days.ago ) }
      let(:non_approved_applications) { create_list(:application, 2, approved_at: nil) }

      it 'returns all applications with an approved_at date' do
        expect(Expa::Application.approveds).to eq [first_approved, second_approved]
      end
    end

    context 'synchronized_approveds' do
      let(:synchronized_applications) { create_list(:application, 4) }
      let(:non_synchronized_applications) { create_list(:application, 4, podio_id: nil) }

      it 'returns all applications with an approved_at date that has been synched with podio' do
        expect(Expa::Application.synchronized_approveds).to match_array synchronized_applications
      end
    end
  end

  describe '#associations' do
    it { is_expected.to belong_to(:exchange_participant) }
  end

  describe 'attributes' do
    it { is_expected.to respond_to(:product) }
    it { is_expected.to respond_to(:tnid) }
    it { is_expected.to respond_to(:podio_sent) }
    it { is_expected.to respond_to(:podio_sent_at) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:product) }
    it { is_expected.to validate_presence_of(:tnid) }

    it do
      expect(Expa::Application.new).to define_enum_for(:product)
        .with(%w[gv ge gt])
    end
  end

  describe 'methods' do
    context 'opportunity_link' do
      let(:application) { build(:application) }

      it 'returns a link to the opportunity' do
        expect(application.opportunity_link).to eq("https://aiesec.org/opportunity/#{application.tnid}")
      end
    end
  end

  it do
    expect(Expa::Application.new).to define_enum_for(:status)
      .with(open: 1, applied: 2, accepted: 3, approved_tn_manager: 4, approved_ep_manager: 5, approved: 6,
            break_approved: 7, rejected: 8, withdrawn: 9,
            realized: 100, approval_broken: 101, realization_broken: 102, matched: 103,
            completed: 104
           )
  end
end
