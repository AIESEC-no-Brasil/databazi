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
    it do
      is_expected.to define_enum_for(:experience)
        .with(%i[language marketing information_technology management])
    end
    it do
      is_expected.to define_enum_for(:scholarity)
        .with(%i[graduating post_graduated almost_graduated graduated])
    end
    it { is_expected.to accept_nested_attributes_for :exchange_participant }
    it { is_expected.to accept_nested_attributes_for :english_level }
  end

  describe '#associations' do
    it { is_expected.to have_one(:exchange_participant).dependent(:destroy) }
    it { is_expected.to have_one(:english_level).dependent(:destroy) }
  end

  describe '#methods' do
    it { is_expected.to delegate_method(:as_sqs).to(:exchange_participant) }
  end
end
