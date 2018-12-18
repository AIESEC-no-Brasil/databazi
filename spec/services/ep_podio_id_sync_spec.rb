require 'pstore'
require 'rails_helper'
# require "#{Rails.root}/lib/expa_api"

describe EpPodioIdSync do

  describe '#call' do
    let(:fake_podio_id) { 12345 }
    let(:ge) { build(:ge_participant) }
    let(:gv) { build(:gv_participant) }
    let(:gt) { build(:gt_participant) }
    let(:storage) { PStore.new('podio_sync_test.pstore') }
    let(:params) { { storage: storage } }

    let(:field_name) { { 'field_id' => 133_074_857, 'values' => [{ 'value' => 'Foo bar' }] } }
    let(:field_email) { { 'field_id' => 133_074_860, 'values' => [{ 'value' => 'foo@bar.com' }] } }
    let(:item) { double('fields', fields: [field_name, field_email], app_item_id: fake_podio_id) }
    let(:ret) { double('Podio::Item', all: [item], count: 100) }

    before do
      allow(GeParticipant).to receive(:find_by)
        .with(hash_including(podio_id: nil)).and_return(ge)
      allow(GvParticipant).to receive(:find_by)
        .with(hash_including(podio_id: nil)).and_return(gv)
      allow(GtParticipant).to receive(:find_by)
        .with(hash_including(podio_id: nil)).and_return(gt)
      # allow(Podio::Item).to receive(:find_by_filter_values).and_call_original
      allow(Podio::Item).to receive(:find_by_filter_values).and_return(ret)
      allow(ge).to receive(:update_attributes)
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

    it 'update podio_id of ep' do
      described_class.call(params)
      expect(ge).to have_received(:update_attributes)
        .with(podio_id: fake_podio_id)
    end

    context 'when ep in podio does not exists on databazi' do
      before do
        allow(GeParticipant).to receive(:find_by)
          .with(hash_including(podio_id: nil)).and_return(nil)
      end

      it 'does not have anything to save' do
        expect(ge).not_to receive(:update_attributes)
        described_class.call(params)
      end
    end

    context 'multiples offset' do
      before do
        storage.transaction do
          storage[:ge_offset] = 10
          storage[:gv_offset] = 20
          storage[:gt_offset] = 30
        end
      end
      context 'ge' do
        it 'ge offset' do
          described_class.call(params)
          expect(Podio::Item).to have_received(:find_by_filter_values)
            .with('17057629', anything, hash_including(offset: 10))
        end

        it 'ge offset done start false' do
          done = storage.transaction{ storage.fetch(:ge_offset_done, false) }
          expect(done).to be false
        end

        it 'end offsets' do
          storage.transaction{ storage[:ge_offset] = 9 }
          described_class.call(params)
          done = storage.transaction{ storage.fetch(:ge_offset_done, false) }
          expect(done).to be true
        end

        it 'search a podio item in database' do
          described_class.call(params)
          expect(GeParticipant).to have_received(:find_by)
            .with(email: 'foo@bar.com', podio_id: nil)
        end
      end

      context 'gv' do
        before do
          storage.transaction do
            storage[:ge_offset_done] = true
          end
        end

        it 'offset' do
          described_class.call(params)
          expect(Podio::Item).to have_received(:find_by_filter_values)
            .with('15290822', anything, hash_including(offset: 20))
        end

        it 'end offsets' do
          storage.transaction{ storage[:gv_offset] = 9 }
          described_class.call(params)
          done = storage.transaction{ storage.fetch(:gv_offset_done, false) }
          expect(done).to be true
        end

        it 'search a podio item in database' do
          described_class.call(params)
          expect(GvParticipant).to have_received(:find_by)
            .with(email: 'foo@bar.com', podio_id: nil)
        end
      end

      context 'gt' do
        before do
          storage.transaction do
            storage[:ge_offset_done] = true
            storage[:gv_offset_done] = true
          end
        end

        it 'gt offset' do
          described_class.call(params)
          expect(Podio::Item).to have_received(:find_by_filter_values)
            .with('17057001', anything, hash_including(offset: 30))
        end

        it 'end offsets' do
          storage.transaction{ storage[:gt_offset] = 9 }
          described_class.call(params)
          done = storage.transaction{ storage.fetch(:gt_offset_done, false) }
          expect(done).to be true
        end

        it 'search a podio item in database' do
          described_class.call(params)
          expect(GtParticipant).to have_received(:find_by)
            .with(email: 'foo@bar.com', podio_id: nil)
        end
      end

    end
  end
end
