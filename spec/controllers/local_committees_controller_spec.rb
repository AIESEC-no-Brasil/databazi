require 'rails_helper'

RSpec.describe LocalCommitteesController, type: :controller do
  describe '#index' do
    subject(:do_index) { get :index }

    let(:response) { JSON.parse(subject.body) }

    it { is_expected.to be_successful }

    describe 'response' do
      context 'with empty list' do
        it { expect(response).to be_empty }
      end

      context 'with filled list' do
        before do
          create_list(:local_committee, 3)
          allow(LocalCommittee).to receive(:active).and_return(LocalCommittee.active)
        end

        it do
          expected = %w[id name podio_id expa_id active]
          expect(response.first.keys).to match_array(expected)
        end

        it { expect(response.count).to eq LocalCommittee.active.count }

        it 'calls for active local committees only' do
          do_index

          expect(LocalCommittee).to have_received(:active)
        end
      end
    end
  end
end
