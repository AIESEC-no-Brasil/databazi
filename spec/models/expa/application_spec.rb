require 'rails_helper'

RSpec.describe Expa::Application, type: :model do
  describe '#associations' do
    it { is_expected.to belong_to(:exchange_participant) }
  end

  it do
    expect(Expa::Application.new).to define_enum_for(:status)
      .with(open: 1, applied: 2, accepted: 3, approved_tn_manager: 4, approved_ep_manager: 5, approved: 6,
            break_approved: 7, rejected: 8, withdrawn: 9,
            realized: 100, approval_broken: 101, realization_broken: 102, matched: 103,
            completed: 104
           )
  end
end
