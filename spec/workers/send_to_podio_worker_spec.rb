require 'rails_helper'

RSpec.describe SendToPodioWorker do
  let(:worker) { described_class.new }

  it { is_expected.to respond_to :perform }

  before do
    SendToPodio.stub(:call)
    worker.perform(nil, test: 'test')
  end

  it { expect(SendToPodio).to have_received(:call) }
end
