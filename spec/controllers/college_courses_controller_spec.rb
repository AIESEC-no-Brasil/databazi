require 'rails_helper'

RSpec.describe CollegeCoursesController, type: :controller do
  describe '#index' do
    subject(:do_index) { get :index }

    let(:response) { JSON.parse(subject.body) }

    it { is_expected.to be_successful }
    it { expect(response).to be_empty }

    describe 'response' do
      before { create_list(:college_course, 3) }

      it 'is properly formatter' do
        expect(response.first.keys).to match_array(%w[id name])
      end

      context 'with no params' do
        it do
          expected = CollegeCourse.all
          expect(response).to match_array(expected.as_json(only: %i[id name]))
        end

        it { expect(response.size).to eq CollegeCourse.count }
      end

      context 'with name param' do
        subject(:do_index) { get :index, params: { name: 'abc' } }

        let!(:first_college_course) do
          create(:college_course, name: 'Bachelor in ABC')
        end
        let!(:second_college_course) do
          create(:college_course, name: 'Abc Master\'s Degree')
        end

        it do
          expected = [first_college_course, second_college_course]
          expect(response).to match_array(expected.as_json(only: %i[id name]))
        end

        it { expect(response.size).to eq 2 }
      end
    end
  end
end
