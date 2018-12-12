require 'rails_helper'
require "#{Rails.root}/lib/expa_api"

RSpec.describe ExpaApplicationSyncScheduler do
  subject { described_class.new }

  describe '#call' do
    let(:paging) { double('paging', total_pages: 10) }
    let(:all_op) { double('all_opportunity_application', paging: paging) }
    let(:data) { double('data', all_opportunity_application: all_op) }
    let(:ret) { double('ExpaReturn', data: data) }

    before do
      allow(EXPAAPI::Client).to receive(:query).and_return(ret)
      allow(Expa::Application).to receive(:maximum)
    end

    it 'get last update_at' do
      subject.call
      expect(Expa::Application).to have_received(:maximum).with('updated_at_expa')
    end

    it 'number of pages from Expa API' do
      described_class.call
      expect(EXPAAPI::Client).to have_received(:query)
    end

    context 'when does not have any application in db' do
      before { allow(Expa::Application).to receive(:maximum).and_return(nil) }

      it 'get applications from beginning of 2018' do
        subject.call
        expect(EXPAAPI::Client).to have_received(:query)
          .with(CountApplications, variables: {
                  from: Date.new(2018, 1, 1), to: Time.now.change(sec: 0)
                })
      end
    end

    context 'when have application in db' do
      before { allow(Expa::Application).to receive(:maximum).and_return(Date.new(2018, 10, 1)) }

      it 'get applications from last update at expa' do
        subject.call
        expect(EXPAAPI::Client).to have_received(:query)
          .with(CountApplications,
                variables: { from: Date.new(2018, 10, 1), to: anything })
      end

      context 'expa return pages' do
        before do
          allow(EXPAAPI::Client).to receive(:query).and_return(double('ExpaReturn', data: data))
          allow(ExpaApplicationSyncWorker).to receive(:perform_async)
        end

        it 'queue 10 pages with right parameters' do
          subject.call
          expect(ExpaApplicationSyncWorker).to have_received(:perform_async).exactly(10).times
        end
      end
    end
  end
end
