require 'rails_helper'
require 'podio_helper'

RSpec.describe RepositoryPodio do
  include PodioHelper
  @podio_ep = nil

  describe '#change_status' do
    let(:exchange_participant) { build(:exchange_participant, status: :applied) }
    let(:application) { build(:application, exchange_participant: exchange_participant) }

    before do
      params = {}
      params['title'] = 'Teste | Sync Podio';
      @podio_ep = RepositoryPodio.create_ep(ENV['PODIO_APP_GV'], params)
    end

    after do
      RepositoryPodio.delete_ep(@podio_ep.item_id)
    end

    it '#change_status' do
      RepositoryPodio.change_status(@podio_ep.item_id, application)
      item = RepositoryPodio.get_item(@podio_ep.item_id)
      field = item.fields.select { |f| f['external_id'] == 'status-expa' }
      expect(field[0]['values'][0]['value']['id']).to be_equal(2)

      field = item.fields.select { |f| f['external_id'] == 'teste-di-data-do-applied' }
      expect(field[0]['values'][0]['start']).to eql(application.applied_at.strftime('%Y-%m-%d %H:%M:%S'))

      field = item.fields.select { |f| f['external_id'] == 'teste-di-data-do-accepted' }
      expect(field[0]['values'][0]['start']).to eql(application.accepted_at.strftime('%Y-%m-%d %H:%M:%S'))
    end
  end

  describe '#map_status' do
    def self.test_map(from, to)
      it "maps status from #{from} to #{to}" do
        expect(described_class.send(:map_status, from)).to eql(to)
      end
    end

    test_map :open, 1
    test_map :applied, 2 # Podio: Applied
    test_map :accepted, 3 # Podio: Accepted
    test_map :approved_tn_manager, 4 # Podio: Approved
    test_map :approved_ep_manager, 4 # Podio: Approved
    test_map :approved, 4 # Podio: Approved
    test_map :break_approved, 5 # Podio: Break Approval
    test_map :rejected, 6 # Podio: Rejected
    test_map :withdrawn, 6 # Podio: Rejected
    test_map :realized, 4 # Podio: Approved
    test_map :approval_broken, 6 # Podio: Rejected
    test_map :realization_broken, 5 # Podio: Break Approval
    test_map :matched, 4 # Podio: Approved
    test_map :completed, 4 # Podio: Approved
  end

  xdescribe '#save_icx_application' do
    # TODO: Think about status mapping, Podio have few status than system
    let(:databazi_application) { build :icx_application_podio }
    # rubocop:disable Metrics/LineLength
    let(:expected_podio_application) do
      {
        title: databazi_application.exchange_participant.fullname,
        'epid': Float(databazi_application.expa_ep_id),
        status: 1,
        email: databazi_application.exchange_participant.email,
        # 'data-de-nascimento': databazi_application.exchange_participant.birthdate,
        'data-do-applied': databazi_application.applied_at,
        'data-do-accepted': databazi_application.accepted_at,
        'data-do-approved': databazi_application.approved_at,
        'data-do-break-approval': databazi_application.break_approved_at,
        # 'background-academico': "<p>#{databazi_application.academic_experience}</p>",
        'opportunity-name': "<p>#{databazi_application.opportunity_name}</p>",
        'expa-opportunity-id': databazi_application.tnid,
        'host-lc': databazi_application&.host_lc&.podio_id,
        'home-lc': databazi_application&.home_lc&.podio_id,
        'home-mc': 1023733737,
        'celular': databazi_application.exchange_participant.cellphone,
        'sdg-de-interesse': 1
      }
    end
    # rubocop:enable Metrics/LineLength
    subject { described_class.save_icx_application(databazi_application) }

    after do
      described_class.delete_icx_application(subject.item_id)
    end

    it 'save into Podio' do
      expect(map_podio(subject)).to include(expected_podio_application)
    end
  end

  describe '#status_to_podio' do
    it 'expected applications statuses', type: :model do
      expect(Expa::Application.new).to define_enum_for(:status).with(
        open: 1, applied: 2, accepted: 3, approved_tn_manager: 4,
        approved_ep_manager: 5, approved: 6, break_approved: 7, rejected: 8,
        withdrawn: 9, realized: 100, approval_broken: 101,
        realization_broken: 102, matched: 103, completed: 104, finished: 105 )
    end

    def self.test_map(from, to)
      it "map #{from} to #{to}" do
        expect(described_class.send(:status_to_podio, from)).to eql(to)
      end
    end

    #
    test_map(:open, 6)
    test_map(:approved_tn_manager, 6)
    test_map(:approved_ep_manager, 6)
    test_map(:withdrawn, 6)
    test_map(:realized, 6)
    test_map(:approval_broken, 6)
    test_map(:realization_broken, 6)
    test_map(:completed, 6)
    test_map(:matched, 6)
    test_map(:open, 6)
    test_map(:applied, 1)
    test_map(:accepted, 2)
    test_map(:approved, 3)
    test_map(:break_approved, 4)
    test_map(:rejected, 5)
  end
end