require 'rails_helper'
require_relative '../../lib/repository_podio'

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
end