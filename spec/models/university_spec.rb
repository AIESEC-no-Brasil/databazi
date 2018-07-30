require 'rails_helper'

RSpec.describe University, type: :model do
  describe "#associations" do
    it { is_expected.to have_many :exchange_participants }
  end

  describe '#scopes' do
    describe 'by_name' do
      let!(:university) { create(:university, name: 'University By Name Scope') }
      
      let!(:universities) { create_list(:university, 3) }
      
      context 'with no given param' do
        it { expect(University.by_name).to match_array(University.all) }
        it { expect(University.by_name.count).to eq University.count }
      end

      context 'with given param' do
        it { expect(University.by_name('by name')).to match_array([university]) }
        it { expect(University.by_name('by name').count).to eq 1 }
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
