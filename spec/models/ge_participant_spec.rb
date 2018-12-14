require 'rails_helper'

RSpec.describe GeParticipant, type: :model do
  describe '#associations' do
    it { is_expected.to have_one(:exchange_participant).dependent(:destroy) }
    it { is_expected.to have_one(:english_level).dependent(:destroy) }
  end

  describe '#attributes' do
    it { is_expected.to respond_to :birthdate }
    it { is_expected.to respond_to :cellphone }
    it { is_expected.to respond_to :email }
    it { is_expected.to respond_to :first_name }
    it { is_expected.to respond_to :fullname }
    it { is_expected.to respond_to :last_name }
    it { is_expected.to respond_to :spanish_level }
    it do
      expect(GeParticipant.new).to define_enum_for(:spanish_level)
        .with(%i[none basic intermediate advanced fluent])
    end
    it { is_expected.to accept_nested_attributes_for :exchange_participant }
    it { is_expected.to accept_nested_attributes_for :english_level }
    it do
      expect(GeParticipant.new).to define_enum_for(:when_can_travel)
        .with(%i[as_soon_as_possible next_three_months
                 next_six_months in_one_year])
    end
    it do
      expect(GeParticipant.new).to define_enum_for(:preferred_destination)
        .with({ brazil: 1, mexico: 2, peru: 3 })
    end
  end

  describe '#validation' do
    it { is_expected.to validate_presence_of :spanish_level }

    context 'when in Argentina' do
      before { allow(subject).to receive(:argentina?).and_return true }

      it { is_expected.to validate_presence_of :when_can_travel }
      it { is_expected.to validate_presence_of :preferred_destination }
    end

    context 'when not in Argentina' do
      before { allow(subject).to receive(:argentina?).and_return false }

      it { is_expected.not_to validate_presence_of :when_can_travel }
      it { is_expected.not_to validate_presence_of :preferred_destination }
    end
  end

  describe '#methods' do
    it { is_expected.to delegate_method(:as_sqs).to(:exchange_participant) }
  end
end
