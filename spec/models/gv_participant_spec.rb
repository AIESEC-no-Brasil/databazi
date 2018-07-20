require 'rails_helper'

RSpec.describe GvParticipant, type: :model do
  describe "#associations" do
    it { is_expected.to have_one(:exchange_participant).dependent(:destroy) }
  end

  describe "#attributes" do
    it { is_expected.to respond_to :fullname }
    it { is_expected.to respond_to :cellphone }
    it { is_expected.to respond_to :email }
    it { is_expected.to respond_to :birthdate }
    it { is_expected.to accept_nested_attributes_for :exchange_participant }
  end
end
