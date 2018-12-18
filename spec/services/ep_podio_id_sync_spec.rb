require 'pstore'
require 'rails_helper'
# require "#{Rails.root}/lib/expa_api"

describe EpPodioIdSync do
  before do
  end

  describe '#call' do
    let(:ge) { build(:ge_participant) }
    let(:gv) { build(:gv_participant) }
    let(:gt) { build(:gt_participant) }
    let(:storage) { PStore.new('podio_sync_test.pstore') }
    let(:params) { { storage: storage } }

    let(:field_name) { { 'field_id' => 133_074_857, 'values' => [{ 'value' => 'Foo bar' }] } }
    let(:field_email) { { 'field_id' => 133_074_860, 'values' => [{ 'value' => 'foo@bar.com' }] } }
    let(:item) { double('fields', fields: [field_name, field_email]) }
    let(:ret) { double('all', all: [item]) }
    let(:fixture) { JSON.parse(File.read("#{Rails.root}/spec/services/json_fixture.json")) }

    before do
      allow(GeParticipant).to receive(:find_by)
        .with(hash_including(podio_id: nil)).and_return(ge)
      allow(GvParticipant).to receive(:find_by)
        .with(hash_including(podio_id: nil)).and_return(gv)
      allow(GtParticipant).to receive(:find_by)
        .with(hash_including(podio_id: nil)).and_return(gt)
      # allow(Podio::Item).to receive(:find_by_filter_values).and_call_original
      allow(Podio::Item).to receive(:find_by_filter_values).and_return(ret)

      #   Clear Pstore
      storage.transaction do
        storage.roots.each do |root|
          storage.delete(root)
        end
      end
    end

    it 'load from Podio 0 offset' do
      described_class.call(params)
      expect(Podio::Item).to have_received(:find_by_filter_values)
        .with(anything, anything, hash_including(offset: 0))
    end

    it 'load another offset on second call' do
      described_class.call(params)
      described_class.call(params) # SECOND CALL
      expect(Podio::Item).to have_received(:find_by_filter_values)
        .with(anything, anything, hash_including(offset: 1))
    end

    it 'search a podio item in database' do
      described_class.call(params)
      expect(GeParticipant).to have_received(:find_by)
        .with(email: 'foo@bar.com', podio_id: nil)
    end

    # it 'load an ep without podio_id' do
    #   described_class.call
    #   expect(GeParticipant).to have_received(:find_by_podio_id)
    # end
  end
end
