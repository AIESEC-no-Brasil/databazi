require 'json_helper'
require 'rails_helper'

RSpec.describe ExpaICXSync do
  include JsonHelper
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

    context 'when returning applications' do
      let(:applications) { get_json('icx_applications') }

      it 'test mock man' do
        puts applications.to_json
        puts applications.data.all_opportunity_application.data[0].person.id
      end
    end
  end
end