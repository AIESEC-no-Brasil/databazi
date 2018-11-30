require 'rails_helper'

RSpec.describe UniversitiesController, type: :controller do
  describe '#index' do
    subject(:do_index) { get :index }

    let(:response) { JSON.parse(subject.body) }

    it { is_expected.to be_successful }
    it { expect(response).to be_empty }

    describe 'response' do
      before { create_list(:university, 3) }

      it 'is properly formatted' do
        expect(response.first.keys).to match_array(%w[id name local_committee_id])
      end

      context 'when filtered by name' do
        let!(:first_university) do
          create(:university, name: 'University of Outra')
        end
        let!(:second_university) do
          create(:university, name: 'Outra University')
        end
        let!(:other_university) do
          create(:university, name: 'OUTRA')
        end

        context 'with no name param' do
          it do
            expect(response).to match_array(
              University.all.as_json(only: %i[id name local_committee_id])
            )
          end
          it { expect(response.size).to eq University.count }
        end

        context 'with name param' do
          subject(:do_index) { get :index, params: { name: 'Óutrã' } }

          it do
            expected = [second_university, first_university, other_university]
            expect(response).to eq(expected.as_json(only: %i[id name local_committee_id]))
          end
          it { expect(response.size).to eq 3 }
        end
      end

      context 'when filtered by limit' do
        let!(:universities) { create_list(:university, 10) }

        context 'with param limit' do
          subject(:do_index) { get :index, params: { limit: 10 } }

          it { expect(response.size).to eq(10) }
        end

        context 'with no param limit' do
          subject(:do_index) { get :index }

          it { expect(response.size).to eq(University.count) }
        end
      end

      context 'with city param' do
        subject(:do_index) { get :index, params: params }

        let(:params) do
          { limit: 10, city: 'Limeira' }
        end

        before do
          create_list(:university, 5)
          create_list(:university, 3, city: 'Limeira')
        end

        it 'returns universities that belong to the committee' do
          expect(response.size).to eq 3
        end
      end
    end
  end
end
