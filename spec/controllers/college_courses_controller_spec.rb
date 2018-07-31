require 'rails_helper'

RSpec.describe CollegeCoursesController, type: :controller do
  describe "#index" do
    let(:response) { JSON.parse(subject.body) }
 
    subject(:do_index) { get :index }

    it { is_expected.to be_successful }

    describe "response" do
      context "empty list" do
        it { expect(response).to be_empty }
      end

      context "filled list" do
        before { create_list(:college_course, 3) }
        
        context 'format' do
          it { expect(response.first.keys).to match_array(['id', 'name']) }
        end

        context 'with no params' do
          it { expect(response).to match_array(CollegeCourse.all.as_json(only: [:id, :name])) }

          it { expect(response.count).to eq CollegeCourse.count }
        end

        context 'with name param' do
          subject(:do_index) { get :index, params: { name: 'abc' } }

          let!(:first_college_course) { create(:college_course, name: 'Bachelor in ABC') }
          let!(:second_college_course) { create(:college_course, name: 'Abc Master\'s Degree') }

          it { expect(response).to match_array([first_college_course, second_college_course].as_json(only: [:id, :name])) }

          it { expect(response.count).to eq([first_college_course, second_college_course].count) }
        end
      end
    end
  end
end
