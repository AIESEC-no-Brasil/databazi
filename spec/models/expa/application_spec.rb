require 'rails_helper'

RSpec.describe Expa::Application, type: :model do
  describe '#associations' do
    it { is_expected.to belong_to(:exchange_participant) }
  end

  it do
    expect(Expa::Application.new).to define_enum_for(:status).with(
      open: 1, applied: 2, accepted: 3, approved: 4,
      break_approved: 5, rejected: 6)
  end
end
