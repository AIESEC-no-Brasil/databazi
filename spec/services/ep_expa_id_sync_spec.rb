require 'rails_helper'
require "#{Rails.root}/lib/expa_api"

RSpec.describe EpExpaIdSync do
  subject { described_class.new }
  let(:check_person_present) { double(id: 123) }
  let(:data) { double(check_person_present: check_person_present) }
  let(:response) { double(data: data) }
  let(:ep) { ExchangeParticipant.new(email: 'foo@bar.com') }

  before do
    allow(ep).to receive(:save)
    # allow(ep).to receive(:email).and_call_original
    allow(ExchangeParticipant)
      .to receive(:find_by).with(
        hash_including(expa_id: nil)
      ).and_return(ep)
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

  it 'update attributes' do
    described_class.call
    expect(ep).to have_attributes(expa_id: 123)
    expect(ep)
      .to have_received(:save)
  end

  context "when don't find ep in expa" do
    before do
      allow(EXPAAPI::Client)
        .to receive(:query).with(
          ExistsQuery, variables: hash_including(email: 'foo@bar.com')
        ).and_return(nil)
    end

    it 'update attributes with expa_id 0' do
      described_class.call
      expect(ep).to have_attributes(expa_id: 0)
      expect(ep)
        .to have_received(:save)
    end
  end
end
