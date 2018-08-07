require 'rails_helper'

RSpec.describe University, type: :model do
  describe '#associations' do
    it { is_expected.to have_many :exchange_participants }
  end

  describe '#scopes' do
    describe 'by_name' do
      subject(:university_list) { University.by_name(name) }

      let(:university) do
        create(:university, name: 'University By Name Scope')
      end
      let(:universities) { create_list(:university, 3) }

      before do
        universities
        university
      end

      context 'with no given param' do
        let(:name) { '' }

        it { is_expected.to match_array(University.all) }
        it { expect(university_list.count).to eq University.count }
      end

      context 'with given param' do
        let(:name) { 'by_name' }

        it { is_expected.to match_array([university]) }
        it { expect(university_list.count).to eq 1 }
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
