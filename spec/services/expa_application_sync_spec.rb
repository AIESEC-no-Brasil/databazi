require 'rails_helper'

RSpec.describe ExpaApplicationSync, aws: true do
  subject {ExpaApplicationSync.new}
  context 'with previous exchange participant' do
    before do
      applications = described_class.new.send(:load_applications, '2018-10-01')
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
        described_class.call
      }.to change(Expa::Application, :count).by_at_least(1)
      expect(Expa::Application.first).to have_attributes(updated_at_expa: anything)
    end
  end

  context 'without previous exchange participant' do
    it 'creates applications' do
      expect {
        described_class.call
      }.to change(Expa::Application, :count)
             .by_at_least(1)
    end
  end
end
