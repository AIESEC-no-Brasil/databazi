require 'json_helper'
require 'rails_helper'
require 'podio_helper'

RSpec.describe ExpaIcxSync do
  include PodioHelper
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

  describe '>>> Integration' do
    let(:expa_applications) { [] }

    context 'without any expa applications to sync' do
      let(:expa_applications) { [] }

      before :each do
        class_double(RepositoryExpaApi,
                     load_icx_applications: expa_applications).as_stubbed_const
      end

      it 'has not any expa application' do
        described_class.call()
        expect(Expa::Application.first).to be_nil
      end
    end

    context 'with expa applications' do
      let(:expa_applications) { RepositoryExpaApi.load_icx_applications(3.month.ago)[0, 1] }

      before :each do
        class_double(RepositoryExpaApi,
                     load_icx_applications: expa_applications).as_stubbed_const
        create(:local_committee, expa_id: expa_applications[0].host_lc.expa_id, podio_id: 306811055)
      end

      after :each do
        RepositoryPodio.delete_icx_application(Expa::Application.first.podio_id)
      end

      # rubocop:disable RSpec/MultipleExpectations, RSpec/ExampleLength
      it 'save expa application into databazi and podio' do
        described_class.call()
        expect(Expa::Application.count).to eq 1
        expect(MemberCommittee.count).to eq 1
        expect(MemberCommittee.first).to have_attributes(
          name: kind_of(String),
          expa_id: kind_of(Integer),
          podio_id: kind_of(Integer)
        )
        application = Expa::Application.first
        expect(application).to have_attributes(
          podio_id: kind_of(Integer)
        )
        podio_item = Podio::Item.find(application.podio_id)
        puts map_podio(podio_item).to_json
      end
      # rubocop:enable RSpec/MultipleExpectations, RSpec/ExampleLength
    end

    context 'with and application, and a update of that application' do
      let(:expa_applications) do
        application = RepositoryExpaApi.load_icx_applications(3.month.ago)[0, 1][0]
        applications = [
          Marshal.load(Marshal.dump(application)),
          Marshal.load(Marshal.dump(application))
        ]
        applications[0].status = :applied
        applications[1].status = :accepted
        applications
      end

      before :each do
        create(:local_committee, expa_id: expa_applications[0].host_lc.expa_id, podio_id: 306811055)
        repo = class_double(RepositoryExpaApi).as_stubbed_const
        allow(repo).to receive(:load_icx_applications)
          .and_return([expa_applications[0]], [expa_applications[1]])
      end

      after :each do
        RepositoryPodio.delete_icx_application(Expa::Application.first.podio_id)
      end

      # rubocop:disable RSpec/MultipleExpectations, RSpec/ExampleLength
      it 'update application ' do
        described_class.call()
        first_podio_id = Expa::Application.first.podio_id
        described_class.call()
        applications = Expa::Application.all
        expect(applications.count).to eql(1)
        expect(first_podio_id).to eql(applications[0].podio_id)
      end
      # rubocop:enable RSpec/MultipleExpectations, RSpec/ExampleLength
    end

  end
end