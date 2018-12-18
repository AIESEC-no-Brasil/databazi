require 'pstore'

class EpPodioIdSync
  def self.call(**args)
    new.call(args)
  end

  def initialize
    Podio.setup(
      api_key: ENV['PODIO_API_KEY'],
      api_secret: ENV['PODIO_API_SECRET']
    )
    Podio.client.authenticate_with_credentials(
      ENV['PODIO_USERNAME'],
      ENV['PODIO_PASSWORD']
    )
  end

  def call(**args)
    default_logger = Logger.new(STDOUT)
    default_logger.level = Logger::WARN
    logger = args[:logger] || default_logger
    storage = args[:storage] || PStore.new('podio_id_sync_default.pstore')
    offset = 0
    storage.transaction { offset = storage.fetch(:ge_offset, 0) }
    logger.info 'EpPodioIdSync.call'
    ep = GeParticipant.find_by_podio_id(nil)

    ret = Podio::Item.find_by_filter_values(
      '17057629',
      {},
      sort_by: 'data-inscricao', sort_desc: false, offset: offset
    )
    File.open('json_fixture.json', 'w') { |file| file.write(ret.to_json) }
    ret.all.each do |item|
      begin
        logger.debug "Keys of fields #{item.fields[0].keys}"
        name = item.fields.select{ |field| field['field_id'] == 133074857 }[0]['values'][0]['value']
        email = item.fields.select{ |field| field['field_id'] == 133074860 }[0]['values'][0]['value']
        logger.debug "Name #{name} Email #{email}"
        GeParticipant.find_by(email: email, podio_id: nil)
      rescue StandardError => ex
        logger.error ex
      end
    end
    logger.info ret.inspect
    storage.transaction { storage[:ge_offset] = offset + 1 }
  end

  private
end
