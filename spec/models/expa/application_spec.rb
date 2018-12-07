require 'rails_helper'

RSpec.describe Expa::Application, type: :model do
  describe '#associations' do
    it { is_expected.to belong_to(:exchange_participant) }
  end
end
