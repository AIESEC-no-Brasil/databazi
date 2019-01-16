require 'rails_helper'

RSpec.describe DelayedCall do
  subject { service }

  let(:params) { { delay: 30, job: 'ExpaApplicationSync' } }

  let(:service) { described_class.new(params) }

  it { is_expected.to respond_to(:call) }
  it { is_expected.to respond_to(:status) }
  it { is_expected.to respond_to(:delay_in_seconds) }
  it { is_expected.to respond_to(:job) }
end
