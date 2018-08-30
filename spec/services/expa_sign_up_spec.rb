require 'rails_helper'

RSpec.describe ExpaSignUp do
  subject { service }

  let(:exchange_participant) do
    create(:exchange_participant,
           fullname: 'Forrest Gump',
           registerable: build(:gv_participant))
  end

  let(:params) { exchange_participant.id }

  let(:service) { described_class.call(params) }

  it { is_expected.to respond_to(:call) }

  it { is_expected.to respond_to(:exchange_participant) }

  it { is_expected.to respond_to(:status) }

  context 'when failure' do
    it 'states as false when given method fails' do
      # expect(SendToExpa.call(invalid_params)).to eq false
    end
  end
end
