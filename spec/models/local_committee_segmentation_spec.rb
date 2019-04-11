require 'rails_helper'

RSpec.describe LocalCommitteeSegmentation, type: :model do
  
	describe '#attributes' do
    it { is_expected.to respond_to :origin_local_committee_id }
    it { is_expected.to respond_to :destination_local_committee_id }
    it { is_expected.to respond_to :program }
    it do
      expect(LocalCommitteeSegmentation.new).to define_enum_for(:program)
        .with({ :gv, :ge, :gt })
    end
  end

  describe '#validations' do
    it { is_expected.to validate_presence_of :origin_local_committee_id }
    it { is_expected.to validate_presence_of :destination_local_committee_id }
    it { is_expected.to validate_presence_of :program }
  end

end
