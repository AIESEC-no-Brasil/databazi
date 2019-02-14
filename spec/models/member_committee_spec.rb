require 'rails_helper'

RSpec.describe MemberCommittee, type: :model do
  describe '#attributes' do
    it { is_expected.to respond_to :name }
    it { is_expected.to respond_to :podio_id }
    it { is_expected.to respond_to :expa_id }
  end

  describe '#associations' do
    it { is_expected.to have_many :local_committees }
  end
end
