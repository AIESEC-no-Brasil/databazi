require 'rails_helper'

RSpec.describe EnglishLevel, type: :model do
  describe "#attributes" do
    it { is_expected.to respond_to :english_level }
    it do
      is_expected.to define_enum_for(:english_level).
        with([:none, :basic, :intermediate, :advanced, :fluent])
    end
  end

  describe "#associations" do
    it { is_expected.to belong_to :englishable }
  end
end
