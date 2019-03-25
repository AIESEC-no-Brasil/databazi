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

    test_map 'rd-station', 0
    test_map 'some_invalid_character_rd-station_some_invalid_character', 0

    test_map 'google', 1
    test_map 'some_invalid_character_google_some_invalid_character', 1

    test_map 'facebook', 2
    test_map 'some_invalid_character_facebook_some_invalid_character', 2

    test_map 'instagram', 3
    test_map 'some_invalid_character_instagram_some_invalid_character', 3

    test_map 'twitter', 4
    test_map 'some_invalid_character_twitter_some_invalid_character', 4

    test_map 'linkedin', 5
    test_map 'some_invalid_character_linkedin_some_invalid_character', 5

    test_map 'site', 6
    test_map 'some_invalid_character_site_some_invalid_character', 6

    test_map 'blog', 7
    test_map 'some_invalid_character_blog_some_invalid_character', 7

    test_map 'offline', 8
    test_map 'some_invalid_character_offline_some_invalid_character', 8

    test_map 'outros', 9
    test_map 'some_invalid_character_outros_some_invalid_character', 9
    test_map 'this domain does not exist', 9
  end

  describe '#utm_medium_to_podio' do
    def self.test_map(from, to)
      it "maps status from #{from} to #{to}" do
        expect(service.send(:utm_medium_to_podio, from)).to eql(to)
      end
    end

    test_map 'banner-home', 0
    test_map 'some_invalid_character_banner-home_some_invalid_character', 0

    test_map 'bumper', 1
    test_map 'some_invalid_character_bumper_some_invalid_character', 1

    test_map 'cartaz', 2
    test_map 'some_invalid_character_cartaz_some_invalid_character', 2

    test_map 'cpc', 3
    test_map 'some_invalid_character_cpc_some_invalid_character', 3

    test_map 'display', 4
    test_map 'some_invalid_character_display_some_invalid_character', 4

    test_map 'email', 5
    test_map 'some_invalid_character_email_some_invalid_character', 5

    test_map 'imagem', 6
    test_map 'some_invalid_character_imagem_some_invalid_character', 6

    test_map 'indicacao', 7
    test_map 'some_invalid_character_indicacao_some_invalid_character', 7

    test_map 'leads-ads', 8
    test_map 'some_invalid_character_leads-ads_some_invalid_character', 8

    test_map 'pop-up', 9
    test_map 'some_invalid_character_pop-up_some_invalid_character', 9

    test_map 'post-blog', 10
    test_map 'some_invalid_character_post-blog_some_invalid_character', 10

    test_map 'post-form', 11
    test_map 'some_invalid_character_post-form_some_invalid_character', 11

    test_map 'post-link', 12
    test_map 'some_invalid_character_post-link_some_invalid_character', 12

    test_map 'search', 13
    test_map 'some_invalid_character_search_some_invalid_character', 13

    test_map 'stories', 14
    test_map 'some_invalid_character_stories_some_invalid_character', 14

    test_map 'trueview', 15
    test_map 'some_invalid_character_trueview_some_invalid_character', 15

    test_map 'video', 16
    test_map 'some_invalid_character_video_some_invalid_character', 16

    test_map 'outros', 17
    test_map 'some_invalid_character_outros_some_invalid_character', 17
    test_map 'this domain does not exist', 17
  end

end
