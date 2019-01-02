require 'rails_helper'
require 'repository_podio'

RSpec.describe SyncPodioApplicationStatus do
  it { expect(described_class).to respond_to(:call) }
  it { expect(described_class.new).to respond_to(:call) }

  describe '#call' do
    let(:sync) { described_class.new }
    let(:applications) { [] }

    before do
      allow(SyncParam).to receive(:first)
      allow(RepositoryPodio).to receive(:change_status)
      # TODO: We could create a Repository Pattern to avoid stub private mthods
      allow(sync).to receive(:last_applications).and_return(applications)
    end

    it 'use SyncParam to get last updated' do
      sync.call
      expect(SyncParam).to have_received(:first)
    end


    context 'when does not have any applications' do
      it 'dont call change status of Podio' do
        sync.call
        expect(RepositoryPodio).not_to have_received(:change_status)
      end
    end

    context 'when some applications to sync' do
      let(:applications) { build_list(:application, 1, status: :open) }

      it 'call change status of Podio' do
        sync.call
        expect(RepositoryPodio).to have_received(:change_status)
      end

      context 'with a pre existent SyncParam' do
        let(:syncParam) { build(:sync_param) }

        before do
          allow(SyncParam).to receive(:first_or_create).and_return(syncParam)
          allow(SyncParam).to receive(:first).and_return(syncParam)
          allow(syncParam).to receive(:update_attributes)
        end

        it 'update SyncParam podio_application_status_last_sync' do
          sync.call
          expect(syncParam).to have_received(:update_attributes)
            .with(hash_including(podio_application_status_last_sync: applications[0].updated_at))
        end
      end
    end
  end
end
