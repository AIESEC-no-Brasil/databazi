require 'rails_helper'

RSpec.describe EnglishLevel, type: :model do
  describe '#attributes' do
    it { is_expected.to respond_to :english_level }
    it do
      is_expected.to define_enum_for(:english_level)
        .with(%i[none basic intermediate advanced fluent])
    end
  end

  describe '#associations' do
    it { is_expected.to belong_to :englishable }
  end

  describe '#to_s' do
    subject(:english_level) { build(:english_level, english_level: 'fluent') }

    it { expect(english_level.to_s).to eq 'fluent' }
  end
end
