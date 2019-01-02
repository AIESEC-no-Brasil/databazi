require 'rails_helper'

RSpec.describe ExpaICXSync do
  it { expect(described_class).to respond_to(:call) }
  it { expect(described_class.new).to respond_to(:call) }
end