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
    let(:expected_ap) { build(:icx_application_expa) }

    it 'return Application class' do
      ap = described_class.send(:map_applications, applications)
      expect(ap[0]).to be_a(Expa::Application)
    end

    # TODO: Finish mapping of Expa ICX Application to databazi
    it 'validate mapping' do
      ap = described_class.send(:map_applications, applications)
      # For match the result. s
      ap[0].exchange_participant_id = expected_ap.exchange_participant_id
      expected_ap.expa_ep_id = ap[0].expa_ep_id
      expect(ap[0]).to have_attributes(expected_ap.attributes)
    end
  end
end