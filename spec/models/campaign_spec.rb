require 'rails_helper'

RSpec.describe Campaign, type: :model do
  describe '#attributes' do
    it { is_expected.to respond_to :utm_source }
    it { is_expected.to respond_to :utm_medium }
    it { is_expected.to respond_to :utm_campaign }
    it { is_expected.to respond_to :utm_term }
    it { is_expected.to respond_to :utm_content }
  end

  describe '#associations' do
    it { is_expected.to have_many(:exchange_participants) }
  end
end
