require 'rails_helper'

RSpec.describe UniversitiesController, type: :controller do
  describe '#index' do
    let(:response) { JSON.parse(subject.body) }
    
    subject(:do_index) { get :index }

    it { is_expected.to be_successful }

    describe 'response' do
      context 'empty list' do
        it { expect(response).to be_empty }
      end

      context 'filled list' do
        before { create_list(:university, 3) }

        context 'format' do
          it { expect(response.first.keys).to match_array(['id', 'name']) }
        end

        context 'with no params' do  
          it { expect(response).to match_array(University.all.as_json(only: [:id, :name])) }

          it { expect(response.count).to eq University.count }
        end

        context 'with name param' do
          subject(:do_index) { get :index, params: { name: 'abc' } }

          let!(:first_university) { create(:university, name: 'ABC University') }
          let!(:second_university) { create(:university, name: 'University of abc') }

          it { expect(response).to eq([first_university, second_university].as_json(only: [:id, :name])) }

          it { expect(response.count).to eq([first_university, second_university].count) }
        end
      end
    end
  end
end
