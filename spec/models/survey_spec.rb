require 'rails_helper'

RSpec.describe Survey, type: :model do
  subject { build(:survey) }

  describe '#attributes' do
    it { is_expected.to respond_to(:collector) }
    it { is_expected.to respond_to(:status) }
    it { is_expected.to respond_to(:name) }
  end

  describe '#validations' do
    it { is_expected.to validate_presence_of(:collector) }
    it { is_expected.to validate_presence_of(:name) }

    it do
      expect(subject).to define_enum_for(:status)
        .with(%i[approved realized finished approval_broken realization_broken])
    end
  end
end
