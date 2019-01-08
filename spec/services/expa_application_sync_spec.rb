require 'rails_helper'

RSpec.describe ExpaApplicationSync, aws: true do
  subject {ExpaApplicationSync.new}
  context 'with previous exchange participant' do
    before do
      applications = described_class.new.send(:load_applications, '2018-10-01', '2018-10-30', 1)
      create(
        :gt_participant,
        exchange_participant: build(
          :exchange_participant,
          expa_id: applications.first.person.id
        )
      )
    end

    it 'creates applications' do
      expect {
        described_class.call('2018-10-01', '2018-10-30', 1)
      }.to change(Expa::Application, :count)
        .by_at_least(1)
    end
  end

  context 'without previous exchange participant' do
    it 'creates applications' do
      expect {
        described_class.call('2018-10-01', '2018-10-30', 1)
      }.to change(Expa::Application, :count)
             .by_at_least(1)
    end
  end
end
