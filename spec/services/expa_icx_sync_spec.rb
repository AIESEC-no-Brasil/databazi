require 'json_helper'
require 'rails_helper'

RSpec.describe ExpaICXSync do
  include JsonHelper
  it { expect(described_class).to respond_to(:call) }
  it { expect(described_class.new).to respond_to(:call) }

  describe '#call' do

    let(:applications) { [] }

    before do
      @expa_repo = class_double('Repos::Expa',
                                load_icx_applications: applications).as_stubbed_const
      @application_repo = class_double('Repos::Applications',
                                       save: applications).as_stubbed_const
      @podio_repo = class_double('RepositoryPodio',
                           save_icx_application: true).as_stubbed_const
    end

    it 'call expa repo' do
      expect(@expa_repo).to receive(:load_icx_applications).with(any_args)
      described_class.call(1.month.ago, 1.day.ago, 0)
    end

    context 'when returning applications' do
      let(:applications) { get_json('icx_applications') }

      it 'sync with database' do
        expect(@application_repo).to receive(:save).with(any_args)
        described_class.call(1.month.ago, 1.day.ago, 0)
      end

      it 'sync with podio' do
        expect(@podio_repo).to receive(:save_icx_application).with(any_args)
        described_class.call(1.month.ago, 1.day.ago, 0)
      end
    end
  end
end