require 'rails_helper'

RSpec.describe GtParticipant, type: :model do
  describe "#attributes" do
    it { is_expected.to respond_to :fullname }
    it { is_expected.to respond_to :cellphone }
    it { is_expected.to respond_to :email }
    it { is_expected.to respond_to :birthdate }
    it { is_expected.to respond_to :scholarity }
    it { is_expected.to respond_to :experience }
    it do
      is_expected.to define_enum_for(:experience).
        with([:language, :marketing, :information_technology, :management])
    end
    it do
      is_expected.to define_enum_for(:scholarity).
        with([:graduating, :post_graduated, :almost_graduated, :graduated])
    end
  end

  describe "#associations" do
    it { is_expected.to have_one(:exchange_participant).dependent(:destroy) }
    it { is_expected.to have_one(:english_level).dependent(:destroy) }
  end
end
