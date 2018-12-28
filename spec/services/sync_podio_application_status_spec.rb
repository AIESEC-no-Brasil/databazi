require 'rails_helper'
require 'repository_podio'

RSpec.describe SyncPodioApplicationStatus do
  it { expect(described_class).to respond_to(:call) }
  it { expect(described_class.new).to respond_to(:call) }

  describe '#call' do
    before do
      puts 'before 1'
      allow(Expa::Application).to receive(:where)
      allow(SyncParam).to receive(:first)
      allow(SyncParam).to receive(:first)
      allow(RepositoryPodio).to receive(:change_status)
    end

    it 'use SyncParam to get last updated' do
      described_class.call
      expect(SyncParam).to have_received(:first)
    end

    it 'search for applications' do
      described_class.call
      expect(Expa::Application).to have_received(:where)
        .with(hash_including(updated_at: 3.months.ago.round))
    end

    context 'when does not have any applications' do
      before do
        puts 'before 2'
      end

      it 'dont call change status of Podio' do
        described_class.call
        expect(RepositoryPodio).not_to have_received(:change_status)
      end
    end
  end
end
