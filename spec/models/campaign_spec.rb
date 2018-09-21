require 'rails_helper'

RSpec.describe Campaign, type: :model do
  describe '#attributes' do
    it { is_expected.to respond_to :source }
    it { is_expected.to respond_to :medium }
    it { is_expected.to respond_to :campaign }
  end

  describe '#associations' do
    it { is_expected.to have_many(:exchange_participants) }
  end
end
