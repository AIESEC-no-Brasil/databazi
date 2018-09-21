require 'rails_helper'

RSpec.describe SignUpWorker do
  let(:worker) { described_class.new }

  before do
    ExpaSignUp.stub(:call)
    worker.perform(nil, test: 'test')
  end

  it { is_expected.to respond_to :perform }
  it { expect(ExpaSignUp).to have_received(:call) }
end
