require 'json_helper'
require 'rails_helper'

RSpec.describe RepositoryExpaApi do
  include JsonHelper

  it '#load_icx_applications' do
    described_class.load_icx_applications(1.week.ago)
  end

  describe '#map_applications' do
    let(:applications) { get_json('icx_applications_full') }
    let(:expected_ap) do
      {
        'status' => 'open',
        'expa_ep_id' => 1900638,
        'applied_at' => Time.parse('2019-01-06T10:15:14Z'),
        'accepted_at' => Time.parse('2019-03-06T10:15:14Z'),
        'approved_at' => Time.parse('2019-03-06T10:15:14Z'),
        'break_approved_at' => Time.parse('2019-03-06T10:15:14Z'),
        'opportunity_name' => '[SHOUT] TEACHER AT YAZIGI CASCAVEL',
        'opportunity_expa_id' => 1036097,
        'sdg_goal_index' => 4,
        'sdg_target_index' => 8,
      }
    end
    let(:expected_ep) do
      {
        'fullname' => 'Carolina Alejandra Tapia Collantes',
        'email' => 'foo@bar.com',
        'cellphone' => '3045839907',
      }
    end

    it 'return Application class' do
      ap = described_class.send(:map_applications, applications)
      expect(ap[0]).to be_a(Expa::Application)
    end

    # TODO: Finish mapping of Expa ICX Application to databazi
    it 'validate mapping' do
      ap = described_class.send(:map_applications, applications)
      # For match the result. s
      expect(ap[0].exchange_participant).to be_a(ExchangeParticipant)
      expect(ap[0].attributes).to include(expected_ap)
      expect(ap[0].exchange_participant.attributes).to include(expected_ep)
    end
  end
end