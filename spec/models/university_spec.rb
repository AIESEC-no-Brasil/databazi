require 'rails_helper'

RSpec.describe University, type: :model do
  describe "#attributes" do
    it { is_expected.to respond_to :name }
    it { is_expected.to respond_to :podio_id }
  end

  describe "#validations" do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :podio_id }
  end

  describe "#associations" do
    it { is_expected.to have_many :exchange_participants }
  end
end
