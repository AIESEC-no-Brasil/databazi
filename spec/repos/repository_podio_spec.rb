require 'rails_helper'

RSpec.describe RepositoryPodio do
  @podio_ep = nil

  before do
    params = {}
    params['title'] = 'Teste | Sync Podio';
    @podio_ep = RepositoryPodio.create_ep(ENV['PODIO_APP_GV'], params)
  end

  after do
    RepositoryPodio.delete_ep(@podio_ep.item_id)
  end

  it '#change_status' do
    RepositoryPodio.change_status(@podio_ep.item_id, 1)
    item = RepositoryPodio.get_item(@podio_ep.item_id)
    field = item.fields.select{ |f| f['external_id'] == 'status-expa' }
    expect(field[0]['values'][0]['value']['id']).to be_equal(1)
  end

  describe '#save_icx_application' do
    let(:application) { described_class.save_icx_application }

    after do
      described_class.delete_icx_application(application.item_id)
    end

    it 'save into Podio' do
      expect(application).to have_attributes({item_id: anything})
      puts application.to_json
    end

  end
end