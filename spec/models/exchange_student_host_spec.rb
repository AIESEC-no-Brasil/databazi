require 'rails_helper'

RSpec.describe ExchangeStudentHost, type: :model do
  describe '#attributes' do
    it { is_expected.to respond_to :fullname }
    it { is_expected.to respond_to :email }
    it { is_expected.to respond_to :cellphone }
    it { is_expected.to respond_to :zipcode }
    it { is_expected.to respond_to :neighborhood }
    it { is_expected.to respond_to :city }
    it { is_expected.to respond_to :state }
    it { is_expected.to respond_to :cellphone_contactable }
  end

  describe '#validations' do
    subject { build(:exchange_student_host) }

    it { is_expected.to validate_presence_of :fullname }
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to validate_presence_of :cellphone }
    it { is_expected.to validate_presence_of :zipcode }
    it { is_expected.to validate_presence_of :neighborhood }
    it { is_expected.to validate_presence_of :city }
    it { is_expected.to validate_presence_of :state }
  end

  describe 'methods' do
    it '#as_sqs format' do
      exchange_student_host = create(:exchange_student_host)
      as_sqs = { exchange_student_host_id: exchange_student_host.id }

      expect(exchange_student_host.as_sqs).to eq as_sqs
    end
  end
end
