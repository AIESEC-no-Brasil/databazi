require 'rails_helper'

RSpec.describe SendToPodioWorker do
  let(:worker) { described_class.new }

  before do
    SendToPodio.stub(:call)
    worker.perform(nil, test: 'test')
  end

  it { is_expected.to respond_to :perform }
  it { expect(SendToPodio).to have_received(:call) }
end
