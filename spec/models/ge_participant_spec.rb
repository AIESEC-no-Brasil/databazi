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
  end

  describe '#validation' do
    it { is_expected.to validate_presence_of :spanish_level }
  end

  describe '#methods' do
    it { is_expected.to delegate_method(:as_sqs).to(:exchange_participant) }
  end
end
