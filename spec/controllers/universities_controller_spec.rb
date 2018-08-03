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
        expect(response.first.keys).to match_array(%w[id name])
      end

      context 'with no params' do
        it do
          expect(response).to match_array(
            University.all.as_json(only: %i[id name])
          )
        end
        it { expect(response.size).to eq University.count }
      end

      context 'with name param' do
        subject(:do_index) { get :index, params: { name: 'abc' } }

        let!(:first_university) do
          create(:university, name: 'ABC University')
        end
        let!(:second_university) do
          create(:university, name: 'University of abc')
        end

        it do
          expected = [first_university, second_university]
          expect(response).to eq(expected.as_json(only: %i[id name]))
        end
        it { expect(response.size).to eq 2 }
      end
    end
  end
end
