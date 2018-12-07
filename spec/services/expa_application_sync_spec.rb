require 'rails_helper'

RSpec.describe ExpaApplicationSync do
  subject {ExpaApplicationSync.new}

  before do
    applications = described_class.new.send(:load_applications)
    create(
      :gt_participant,
      exchange_participant: build(
        :exchange_participant,
        expa_id: applications.first.person.id
      )
    )
  end

  it 'creates applications' do
    expect { described_class.call }.to change(Expa::Application, :count)
      .by_at_least(1)
  end

end
