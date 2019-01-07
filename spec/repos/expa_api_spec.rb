require 'json_helper'
require 'rails_helper'
require "#{::Rails.root}/app/repos/expa_api"

RSpec.describe Repos::ExpaAPI do
  include JsonHelper

  it '#load_icx_applications' do
    described_class.load_icx_applications(1.week.ago, 1.day.ago, 0)
  end

  describe '#map_applications' do
    let(:applications) { get_json('icx_applications_full') }

    it 'return Application class' do
      ap = described_class.send(:map_applications, applications)
      expect(ap).to be_a(Expa::Application)
    end
  end
end