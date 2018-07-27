require 'rails_helper'

RSpec.describe LocalCommittee, type: :model do
  describe "#attributes" do
    it { is_expected.to respond_to :name }
    it { is_expected.to respond_to :podio_id }
    it { is_expected.to respond_to :expa_id }
  end

  describe "#validations" do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :podio_id }
    it { is_expected.to validate_presence_of :expa_id }
  end

  describe "#associations" do
    it { is_expected.to have_many :exchange_participants }
  end
end
