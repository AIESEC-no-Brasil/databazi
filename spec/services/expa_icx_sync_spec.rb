require 'rails_helper'

RSpec.describe ExpaICXSync do
  it { expect(described_class).to respond_to(:call) }
  it { expect(described_class.new).to respond_to(:call) }

  describe '#call' do

    let(:applications) { [] }

    before do
      @repo = class_double('Repos::Expa',
        load_icx_applications: applications).as_stubbed_const
    end

    it 'call expa repo' do
      expect(@repo).to receive(:load_icx_applications).with(any_args)
      described_class.call(1.month.ago, 1.day.ago, 0)
    end
  end
end