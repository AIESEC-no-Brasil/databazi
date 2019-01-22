require 'rails_helper'

RSpec.describe RepositoryPodio do
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
      RepositoryPodio.change_status(@podio_ep.item_id, :open)
      item = RepositoryPodio.get_item(@podio_ep.item_id)
      field = item.fields.select{ |f| f['external_id'] == 'status-expa' }
      expect(field[0]['values'][0]['value']['id']).to be_equal(1)
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
end