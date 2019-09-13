require 'rails_helper'

RSpec.describe ExpaSignUp do
  ENV['EXPA_SIGNUP_URL'] = 'https://auth-staging.aiesec.org/users.json'

  subject { service }

  let(:service) { described_class.new(params) }

  let(:local_committee_id) { create(:local_committee, expa_id: 1248).id }

  let(:exchange_participant) do
    create(:exchange_participant,
           fullname: 'Forrest Gump',
           email: Faker::Internet.email,
           cellphone: '99999999999',
           password: "Password123",
           local_committee_id: local_committee_id,
           cellphone_contactable: true,
           expa_id: nil,
           registerable: build(:gv_participant)
          )
  end

  let(:params) { { exchange_participant_id: exchange_participant.id }.stringify_keys }

  it { is_expected.to respond_to(:call) }

  it { is_expected.to respond_to(:exchange_participant) }

  it { is_expected.to respond_to(:status) }

  describe 'success' do
    it 'creates user' do
      res = service.call
      expect(res.code).to eq 201
    end

    it 'updates user expa_id' do
      res = service.call

      exchange_participant.reload
      expect(exchange_participant.expa_id).to eq res.parsed_response['person_id']
    end
  end
end
