require 'rails_helper'
require "#{Rails.root}/lib/expa_api"

RSpec.describe EpExpaIdSync, aws: true do
  subject { described_class.new }

  let(:check_person_present) { double(id: 123) }
  let(:data) { double(check_person_present: check_person_present) }
  let(:response) { double(data: data) }
  let(:ep) do
    create(:gv_participant,
           exchange_participant: build(:exchange_participant,
                                       email: 'foo@bar.com'))
      .exchange_participant
  end

  before do
    allow(ep).to receive(:save)
    allow(ExchangeParticipant)
      .to receive(:find_by).and_return(ep)
    allow(EXPAAPI::Client)
      .to receive(:query).with(
        ExistsQuery, variables: hash_including(email: 'foo@bar.com')
      ).and_return(response)
  end

  it 'load eps without expa_id' do
    described_class.call
    expect(ExchangeParticipant).to have_received(:find_by)
  end

  it 'check expa' do
    described_class.call
    expect(EXPAAPI::Client)
      .to have_received('query')
      .with(ExistsQuery, variables: hash_including(email: 'foo@bar.com'))
  end

  context 'when exchange participant exists on expa' do
    before { described_class.call }

    it 'updates expa_id with id fetched from expa' do
      expect(ep).to have_attributes(expa_id: 123)
    end

    it 'is saved' do
      expect(ep).to have_received(:save)
    end
  end

  context 'when exchange participant doesnt exist on expa' do
    before do
      allow(EXPAAPI::Client)
        .to receive(:query).with(
          ExistsQuery, variables: hash_including(email: 'foo@bar.com')
        ).and_return(nil)

      described_class.call
    end

    it 'updates expa_id with 0' do
      expect(ep).to have_attributes(expa_id: 0)
      expect(ep).to have_received(:save)
    end
  end
end
