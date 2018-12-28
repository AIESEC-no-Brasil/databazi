require 'rails_helper'

RSpec.describe SyncPodioApplicationStatus do
  it { expect(described_class).to respond_to(:call) }
  it { expect(described_class.new).to respond_to(:call) }

  describe '#call' do
    before do
      # TODO: We should create a Repository pattern to avoid these dysfunctions
      allow(Expa::Application).to receive(:where)
      allow(SyncParam).to receive(:first)
      described_class.call
    end

    it { expect(SyncParam).to have_received(:first) }

    it {
      expect(Expa::Application).to have_received(:where)
        .with(hash_including(updated_at: 3.months.ago.round))
    }
  end
end
