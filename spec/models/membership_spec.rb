require 'rails_helper'

RSpec.describe Membership, type: :model do
  it { is_expected.to belong_to :college_course }

  it { is_expected.to validate_presence_of :fullname }
  it { is_expected.to validate_presence_of :birthdate }
  it { is_expected.to validate_presence_of :email }
  it { is_expected.to validate_presence_of :cellphone }
  it { is_expected.to validate_presence_of :city }
  it { is_expected.to validate_presence_of :state }
  it { is_expected.to validate_presence_of :cellphone_contactable }
  it { is_expected.to validate_presence_of :college_course }
  it { is_expected.to validate_presence_of :nearest_committee }
end
