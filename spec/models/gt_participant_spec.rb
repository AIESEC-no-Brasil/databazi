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
        .with(%i[brazil mexico india romania colombia
                 panama costa_rica hungary])
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
    it { is_expected.to validate_presence_of :preferred_destination }
  end
end
