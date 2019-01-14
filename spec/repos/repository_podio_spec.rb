require 'rails_helper'
require 'podio_helper'

RSpec.describe RepositoryPodio do
  include PodioHelper
  @podio_ep = nil

  describe '#change_status' do
    before do
      params = {}
      params['title'] = 'Teste | Sync Podio';
      @podio_ep = RepositoryPodio.create_ep(ENV['PODIO_APP_GV'], params)
    end

    after do
      RepositoryPodio.delete_ep(@podio_ep.item_id)
    end

    it '#change_status' do
      RepositoryPodio.change_status(@podio_ep.item_id, 1)
      item = RepositoryPodio.get_item(@podio_ep.item_id)
      field = item.fields.select{ |f| f['external_id'] == 'status-expa' }
      expect(field[0]['values'][0]['value']['id']).to be_equal(1)
    end
  end

  describe '#save_icx_application' do
    # TODO: Think about status mapping, Podio have few status than system
    let(:databazi_application) { build :icx_application }
    # rubocop:disable Metrics/LineLength
    let(:expected_podio_application) do
      {
        title: databazi_application.exchange_participant.fullname,
        'ep-id': Float(databazi_application.expa_ep_id),
        status: 1,
        email: databazi_application.exchange_participant.email,
        'data-de-nascimento': databazi_application.exchange_participant.birthdate,
        'data-do-applied': databazi_application.applied_at,
        'data-do-accepted': databazi_application.accepted_at,
        'data-do-approved': databazi_application.approved_at,
        'data-do-break-approval': databazi_application.break_approved_at,
        'background-academico': "<p>#{databazi_application.academic_experience}</p>",
        'opportunity-name': "<p>#{databazi_application.opportunity_name}</p>",
        'op-id': databazi_application.opportunity_expa_id,
      }
    end
    # rubocop:enable Metrics/LineLength
    let(:application) { described_class.save_icx_application(databazi_application) }

    after do
      described_class.delete_icx_application(application.item_id)
    end

    it 'save into Podio' do
      expect(application).to have_attributes({item_id: anything})
      expect(map_podio(application)).to include(expected_podio_application)
    end
  end

  describe '#status_to_podio' do
    it 'expected applications statuses', type: :model do
      expect(Expa::Application.new).to define_enum_for(:status).with(
        open: 1, applied: 2, accepted: 3, approved: 4,
        break_approved: 5, rejected: 6)
    end

    it 'map :open to Other' do
      expect(described_class.send(:status_to_podio, :open)).to eql(6)
    end

    it 'map :applied to Applied' do
      expect(described_class.send(:status_to_podio, :applied)).to eql(1)
    end

    it 'map :accepted to Accepted' do
      expect(described_class.send(:status_to_podio, :accepted)).to eql(2)
    end

    it 'map :approved to Approved' do
      expect(described_class.send(:status_to_podio, :approved)).to eql(3)
    end

    it 'map :break_approved to Break Approval' do
      expect(described_class.send(:status_to_podio, :break_approved)).to eql(4)
    end

    it 'map :rejected to Rejected' do
      expect(described_class.send(:status_to_podio, :rejected)).to eql(5)
    end
  end
end