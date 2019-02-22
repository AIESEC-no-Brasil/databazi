require 'rails_helper'

RSpec.describe SurveyHistory, type: :model do
  subject { build(:survey_history) }

  describe '#attributes' do
    it { is_expected.to respond_to(:podio_id) }
    it { is_expected.to respond_to(:surveys) }
  end

  describe '#validations' do
    it { is_expected.to validate_presence_of(:podio_id) }
  end
end
