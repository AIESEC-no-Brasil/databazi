require 'rails_helper'

RSpec.describe LocalCommittee, type: :model do
  describe '#attributes' do
    it { is_expected.to respond_to :name }
    it { is_expected.to respond_to :podio_id }
    it { is_expected.to respond_to :expa_id }
    it { is_expected.to respond_to :active }
  end

  describe '#validations' do
    it { is_expected.to validate_presence_of :name }
    xit { is_expected.to validate_presence_of :podio_id }
    it { is_expected.to validate_presence_of :expa_id }
  end

  describe '#associations' do
    it { is_expected.to have_many :exchange_participants }
    it { is_expected.to have_many :universities }
  end

  describe 'active committees' do
    let!(:local_committees) { create_list(:local_committee, 3) }
    let!(:inactive_committee) { create(:local_committee, active: false) }

    subject(:local_committees_list) { LocalCommittee.active }

    it { is_expected.to match_array(local_committees) }

    it { expect(local_committees_list.count).to eq 3 }
  end
end