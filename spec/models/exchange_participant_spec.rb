require 'rails_helper'

RSpec.describe ExchangeParticipant, type: :model do
  describe "#attributes" do
    it { is_expected.to respond_to :fullname }
    it { is_expected.to respond_to :cellphone }
    it { is_expected.to respond_to :email }
    it { is_expected.to respond_to :birthdate }
  end

  describe "#validations" do
    it { is_expected.to validate_presence_of :fullname }
    it { is_expected.to validate_presence_of :cellphone }
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to validate_uniqueness_of :email }
    it { is_expected.to validate_presence_of :birthdate }
  end

  describe "#associations" do
    it { is_expected.to belong_to :registerable }
    it { is_expected.to belong_to :local_committee }
    it { is_expected.to belong_to :college_course }
  end
end
