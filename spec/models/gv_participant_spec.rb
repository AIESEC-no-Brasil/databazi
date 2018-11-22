require 'rails_helper'

RSpec.describe GvParticipant, type: :model do
  describe '#associations' do
    it { is_expected.to have_one(:exchange_participant).dependent(:destroy) }
  end

  describe '#attributes' do
    it { is_expected.to respond_to :birthdate }
    it { is_expected.to respond_to :cellphone }
    it { is_expected.to respond_to :email }
    it { is_expected.to respond_to :first_name }
    it { is_expected.to respond_to :fullname }
    it { is_expected.to respond_to :last_name }
    it { is_expected.to accept_nested_attributes_for :exchange_participant }
    it do
      expect(GvParticipant.new).to define_enum_for(:when_can_travel)
        .with(%i[as_soon_as_possible next_three_months
                 next_six_months in_one_year])
    end
  end

  describe '#methods' do
    it { is_expected.to delegate_method(:as_sqs).to(:exchange_participant) }
  end

  describe '#validation' do
    context 'when in Argentina' do
      before { allow(subject).to receive(:argentina?).and_return true }
      it { is_expected.to validate_presence_of :when_can_travel }
    end

    context 'when not in Argentina' do
      before { allow(subject).to receive(:argentina?).and_return false }
      it { is_expected.not_to validate_presence_of :when_can_travel }
    end
  end
end
