require 'rails_helper'

RSpec.describe SyncPodioApplicationStatus do
  subject { described_class.new }

  it { expect(described_class).to respond_to(:call) }
  it { is_expected.to respond_to(:call) }
end
