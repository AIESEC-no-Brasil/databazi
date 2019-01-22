require 'json_helper'
require 'rails_helper'

RSpec.describe ExpaIcxSync do
  include JsonHelper
  it { expect(described_class).to respond_to(:call) }
  it { expect(described_class.new).to respond_to(:call) }

  describe '#call' do

    let(:applications) { [] }

    before do
      @expa_repo = class_double(RepositoryExpaApi,
                                load_icx_applications: applications).as_stubbed_const
      @application_repo = class_double('Repos::Applications',
                                       save_icx_from_expa: applications).as_stubbed_const
      @podio_repo = class_double('RepositoryPodio',
                           save_icx_application: true).as_stubbed_const
    end

    it 'call expa repo' do
      expect(@expa_repo).to receive(:load_icx_applications).with(any_args)
      described_class.call()
    end

    context 'when returning applications' do
      let(:applications) { get_json('icx_applications') }

      xit 'sync with database' do
        expect(@application_repo).to receive(:save_icx_from_expa).with(any_args)
        described_class.call()
      end

      xit 'sync with podio' do
        expect(@podio_repo).to receive(:save_icx_application).with(any_args)
        described_class.call()
      end
    end
  end
end