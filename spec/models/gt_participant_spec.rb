require 'rails_helper'

RSpec.describe GtParticipant, type: :model do
  describe '#attributes' do
    it { is_expected.to respond_to :birthdate }
    it { is_expected.to respond_to :cellphone }
    it { is_expected.to respond_to :email }
    it { is_expected.to respond_to :experience }
    it { is_expected.to respond_to :first_name }
    it { is_expected.to respond_to :fullname }
    it { is_expected.to respond_to :last_name }
    it { is_expected.to respond_to :scholarity }
    it { is_expected.to accept_nested_attributes_for :exchange_participant }
    it { is_expected.to accept_nested_attributes_for :english_level }
    it { is_expected.to accept_nested_attributes_for :experience }
    it do
      expect(GtParticipant.new).to define_enum_for(:preferred_destination)
        .with({ none: 0, brazil: 4, colombia: 5, costa_rica: 6, hungary: 7,
                                india: 8, mexico: 9, panama: 10, romania: 11 })
    end
    it do
      expect(GtParticipant.new).to define_enum_for(:work_experience)
        .with(%i[none more_than_6_months more_than_a_year])
    end
  end

  describe '#associations' do
    it { is_expected.to have_one(:exchange_participant).dependent(:destroy) }
    it { is_expected.to have_one(:english_level).dependent(:destroy) }
    it { is_expected.to have_one(:experience).dependent(:destroy) }
  end

  describe '#methods' do
    it { is_expected.to delegate_method(:as_sqs).to(:exchange_participant) }
  end

  describe '#validation' do
    context 'when in Argentina' do
      before { allow(subject).to receive(:argentina?).and_return true }
      it { is_expected.to validate_presence_of :preferred_destination }
    end

    context 'when not in Argentina' do
      before { allow(subject).to receive(:argentina?).and_return false }
      it { is_expected.not_to validate_presence_of :preferred_destination }
    end
  end
end
