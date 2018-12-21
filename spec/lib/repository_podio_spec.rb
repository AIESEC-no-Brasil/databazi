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

  it '1 + 1' do
    RepositoryPodio.create_ep
  end
end