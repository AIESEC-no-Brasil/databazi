require 'rails_helper'

RSpec.describe CollegeCourse, type: :model do
  describe "#associations" do
    it { is_expected.to have_many :exchange_participants }
  end

  describe '#scopes' do
    context 'by_name' do
      let!(:college_course) { create(:college_course, name: 'Bachelor By Name Scope') }

      let!(:college_courses) { create_list(:college_course, 3) }

      context 'with no given param' do
        it { expect(CollegeCourse.by_name).to match_array(CollegeCourse.all) }
        it { expect(CollegeCourse.by_name.count). to eq CollegeCourse.count }
      end

      context 'with given param' do
        it { expect(CollegeCourse.by_name('by name')).to match_array([college_course]) }

        it { expect(CollegeCourse.by_name('by name').count).to eq 1 }
      end
    end
  end

  describe "#attributes" do
    it { is_expected.to respond_to :name }
    it { is_expected.to respond_to :podio_id }
  end

  describe "#validations" do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :podio_id }
  end
end
