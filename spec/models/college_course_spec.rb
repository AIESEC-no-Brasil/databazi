require 'rails_helper'

RSpec.describe CollegeCourse, type: :model do
  describe '#associations' do
    it { is_expected.to have_many :exchange_participants }
  end

  describe '#scopes' do
    describe 'by_name' do
      subject(:course_list) { CollegeCourse.by_name(name) }

      let(:college_course) do
        create(:college_course, name: 'Bachelor By Name Scope')
      end
      let(:college_courses) { create_list(:college_course, 3) }

      before do
        college_courses
        college_course
      end

      context 'with no given param' do
        let(:name) { '' }

        it { is_expected.to match_array(CollegeCourse.all) }
        it { expect(course_list.count).to eq CollegeCourse.count }
      end

      context 'with given param' do
        let(:name) { 'by_name' }

        it { is_expected.to match_array([college_course]) }
        it { expect(course_list.count).to eq 1 }
      end
    end
  end

  describe '#attributes' do
    it { is_expected.to respond_to :name }
    it { is_expected.to respond_to :podio_id }
  end

  describe '#validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :podio_id }
  end
end
