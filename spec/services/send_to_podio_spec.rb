require 'rails_helper'

RSpec.describe SendToPodio do
  subject { service }

  let(:params) do
    {
      'email' => 'test@example.com',
      'fullname' => 'John Test',
      'cellphone' => '+5523998989898',
      'birthdate' => '1994-04-04'
    }
  end
  let(:service) { described_class.new(params) }
  let(:client_double) { instance_double(Podio::Client) }
  let(:oauth_double) { instance_double(Podio::OAuthToken) }

  before do
    client_double.stub(:authenticate_with_credentials) { oauth_double }
    allow(oauth_double).to receive(:expires_at).and_return(Time.now)
    Podio.stub(:client) { client_double }
    Podio.stub(:setup)
    Podio::Item.stub(:create) { instance_double(Podio::Item) }
  end

  it { is_expected.to respond_to(:call) }

  it { is_expected.to respond_to(:params) }

  it { is_expected.to respond_to(:status) }

  it 'is truthy', podio: true do
    expect(described_class.call(params)).to be_truthy
  end

  it 'setups podio', podio: true do
    described_class.call(params)

    expect(Podio).to have_received(:setup)
  end
end
