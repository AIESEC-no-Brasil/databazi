class UpdatePodioId
  def self.call(params)
    new(params).call
  end

  attr_reader :params, :status

  def initialize(params)
    @podio_id = params['podio_id']
    @status = true
  end

  def call
    item = fetch_item

    old_item_id = fetch_old_item_id(item)

    exchange_participant = ExchangeParticipant.find_by(podio_id: old_item_id) if old_item_id

    if exchange_participant
      @status = false unless exchange_participant.update_attribute(:podio_id, @podio_id)
    end

    @status
  end

  private

  def fetch_item
    RepositoryPodio.get_item(@podio_id)
  end

  def fetch_old_item_id(item)
    field = item.fields.select { |f| f['external_id'] == 'old-item-id' }.first
    field['values'][0]['value'] if field
  end
end
