require 'rails_helper'

RSpec.describe SendToPodio do
  subject { service }

  let!(:ge_participant) { create(:ge_participant, exchange_participant: build(:exchange_participant)) }

  let(:params) do
    {
      'email' => 'test@example.com',
      'fullname' => 'John Test',
      'cellphone' => '+5523998989898',
      'birthdate' => '1994-04-04',
      'exchange_participant_id' => ge_participant.exchange_participant.id
    }
  end
  let(:service) { described_class.new(params) }
  let(:client_double) { instance_double(Podio::Client) }
  let(:oauth_double) { instance_double(Podio::OAuthToken) }

  # before do
  #   client_double.stub(:authenticate_with_credentials) { oauth_double }
  #   allow(oauth_double).to receive(:expires_at).and_return(Time.now)
  #   Podio.stub(:client) { client_double }
  #   Podio.stub(:setup)
  #   Podio::Item.stub(:create) { instance_double(Podio::Item) }
  # end

  it { is_expected.to respond_to(:call) }

  it { is_expected.to respond_to(:params) }

  it { is_expected.to respond_to(:gx_participant) }

  it { is_expected.to respond_to(:status) }

  # it { expect(described_class.call(params)).to be_truthy }

  # it 'setups podio' do
  #   described_class.call(params)

  #   expect(Podio).to have_received(:setup)
  # end

  describe '#utm_source_to_podio' do
    def self.test_map(from, to)
      it "maps status from #{from} to #{to}" do
        expect(service.send(:utm_source_to_podio, from)).to eql(to)
      end
    end

    test_map 'rdstation', 1
    test_map 'google', 2
    test_map 'facebook', 3
    test_map 'facebook-ads', 11
    test_map 'instagram', 4
    test_map 'twitter', 5
    test_map 'twitter-ads', 12
    test_map 'linkedin', 6
    test_map 'linkedin-ads', 13
    test_map 'youtube', 14
    test_map 'site', 7
    test_map 'blog', 8
    test_map 'offline', 9
    test_map 'outros', 10
    test_map 'this domain does not exist', 10
  end

  describe '#utm_medium_to_podio' do
    def self.test_map(from, to)
      it "maps status from #{from} to #{to}" do
        expect(service.send(:utm_medium_to_podio, from)).to eql(to)
      end
    end

    test_map 'banner', 19
    test_map 'banner-home', 1
    test_map 'pop-up', 10
    test_map 'post-form', 12
    test_map 'imagem', 7
    test_map 'interacao', 20
    test_map 'post-blog', 11
    test_map 'post-link', 13
    test_map 'stories', 15
    test_map 'video', 17
    test_map 'lead-ads', 9
    test_map 'cpc', 4
    test_map 'display', 5
    test_map 'search', 14
    test_map 'imagem-unica', 21
    test_map 'cartaz', 3
    test_map 'evento', 22
    test_map 'indicacao', 8
    test_map 'outro', 18
    test_map 'panfleto', 23
    test_map 'email', 6
    test_map 'bumper', 2
    test_map 'trueview', 16
    test_map 'this domain does not exist', 18
  end

end
